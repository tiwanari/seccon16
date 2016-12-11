require 'json'
require 'parallel'

N = 128
P = 79228162514264337593543950319

def decrypt(enc, priv_key)
  ret = 0
  enc.each do |c, v|
    mul = (v == []) ? 1 : v.map{|a| priv_key[a] }.inject(:*)
    ret = (ret + c * mul) % P
  end
  ret
end

def gen_priv
  base = Array.new(N) { 0 }

  N.times do |i|
      base[i] = 1
      base.permutation(N)
  end
end

enc = JSON.load(File.open("enc.txt").read)
pub = JSON.load(File.open("pub_key.txt").read)
p "target sum: #{pub[0]}" # sum がこれになって欲しい
key = pub[1] # key
# p key

class Array
  def cartesian_power(n)
    current = [0] * n
    last = [size - 1] * n

    loop do
      yield current.reverse.collect { |i| self[i] }
      break if current == last

      (0...n).each do |index|
        current[index] += 1
        current[index] %= size

        break if current[index] > 0
      end
    end
  end
end


[0, 1].cartesian_power(N) do |cand|
    # p cand
    priv_key = cand

    sum = priv_key.zip(key).map{|a,b| a * b}.inject(:+) % P
    # p "sum: #{sum}"

    if sum == pub[0] then
        dec = decrypt(enc, priv_key)

        # decode
        plain = [dec.to_s(16)].pack("H*")

        # p "length: #{plain.length}"
        # # 12 文字みたい
        # # SECCON{.} で 8 文字使うからあと 4 文字? それとも {} の中だけ出てる?

        p "plain: #{plain}"
        break
    end
end
