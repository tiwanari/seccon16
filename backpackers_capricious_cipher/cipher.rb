require 'json'
require 'pp'

N = 128
P = 79228162514264337593543950319

# 呼ばれ方は multiply([[rand(P), [i]], [rand(P), []]], t)
# e.g., t = [[-sum, []],
#            [key[0], [0]], [key[1], [1]], ...]
def multiply(a, b)
  r = []
  a.each do |t|     # [[rand(P), [i]], [rand(P), []]]
    b.each do |s|   # [[-sum, []], [key[0], [0]], [key[1], [1]], ...]
      # 1: rand_P * (-sum / key)  %  P
      # 2: ([i] / []) + ([] / [j])
      r.push [t[0] * s[0] % P, t[1] + s[1]]
    end
  end
  r
end

def add(a, b)
  a + b
end

# 呼ばれ方は
# r = normalize(add(r, multiply([[rand(P), [i]], [rand(P), []]], t))) や
# r = normalize(add(r, [[p, [i,i]], [-p, [i]]])) みたいな
def normalize(a)
  r = []
  # a = r +
  #     [ [p, [i,i]], [-p, [i]] ]
  #
  # step1: b を sort しておく (index)
  # step2: b で group (g) (= index) にまとめる
  # step3: まとめたグループごとに a を足し合わせて，P で割った余り を値とする
  #        そのときの共通する g は一緒につける (第二要素)
  a.map{|a,b| [a, b.sort] }.group_by{|a,b| b}.each do |g,p|
    r.push [p.map{|a,b| a }.inject(:+) % P, g]
  end
  # 最後に b でもう一度ソートする
  r.sort_by{|a,b| b}
end

def gen_private_key
  key = Array.new(N) { rand(P) }            # N 個の乱数からなる配列
  priv_key = Array.new(N) { rand(2) }       # N 個の 0 or 1 からなる配列 (NOTE: これが知りたい!!!!)
  sum = priv_key.zip(key).map{|a,b|a*b}.inject(:+) % P # priv_key[i] (0 or 1) * key[i] の和を取って P で割る
  pub_key = [sum, key]                      # pub = [sum, [key[0], key[1], ...]]
  return [pub_key, priv_key]
end

def encrypt(message, pub_key)
  fail 'Message too long' unless 0 <= message && message < P

  # メッセージと空配列を要素とする配列
  r = [[message, []]]
  # r = [[25770989336925895979047025930, []]]

  # pub_key[0] は sum, pub_key[1] は key
  # key に index 番号をつけて，inject で配列を結合しているだけ
  t = [[-pub_key[0], []]] \
        + pub_key[1].map.with_index {|a,i| [[a, [i]]]}.inject(:+)
  # e.g., t = [[-65069188491199659342297195576, []],
  #            [66517666182343038841961092439, [0]], [64045559398202929660224403219, [1]], ...]

  # === 1 段階目 ===
  N.times do |i|
    # r +
    #   (  [ [rand_P, [i] ], [rand_P, [] ] ]  *  t  )
    # r, t は上記参照
    r = normalize(add(r, multiply([[rand(P), [i]], [rand(P), []]], t)))

    # multiply の結果は，以下の2要素を持つ要素の配列
    # 1: rand_P * (-sum / key)  %  P
    # 2: ([i] / []) + ([] / [j])

    # add はただの +
    # ここでは配列の結合
  end

  # === 2 段階目 ===
  N.times do |i|
    p = rand(P)
    # r +
    #   [[ p, [i, i] ], [ -p, [i] ]]
    # NOTE: ここでは同じ p が使われている
    r = normalize(add(r, [[p, [i,i]], [-p, [i]]]))
  end
  r
end

def decrypt(enc, priv_key)
  ret = 0
  enc.each do |c, v|
    mul = (v == []) ? 1 : v.map{|a| priv_key[a] }.inject(:*)
    ret = (ret + c * mul) % P
  end
  ret
end

message = File.read("flag.txt").unpack("H*")[0].to_i(16) # テキストを16進数で表し直してる
pub_key, priv_key = gen_private_key
enc = encrypt(message, pub_key) # enc = [[, []], ...]
File.write("pub_key.txt", pub_key.to_json)
File.write("priv_key.txt", priv_key.to_json)
File.write("enc.txt", enc.to_json)
fail 'Encryption Failed' unless message == decrypt(enc, priv_key) # ただのチェック
