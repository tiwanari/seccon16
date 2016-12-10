# k: ????????????
# p: SECCON{???????????????????????????????????}
# c: LMIG}RPEDOEEWKJIQIWKJWMNDTSR}TFVUFWYOCBAJBQ
# k=key, p=plain, c=cipher, md5(p)=f528a6ab914c1ecf856a1d93103948fe

require 'digest/md5'

TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ{}"


P = "SECCON{???????????????????????????????????}"
C = "LMIG}RPEDOEEWKJIQIWKJWMNDTSR}TFVUFWYOCBAJBQ"


def calc_key(c, p)
    TABLE[(TABLE.index(c) - TABLE.index(p) + TABLE.size) % TABLE.size]
end

# 最初の 7 個は SECCON{ を暗号化したものなので鍵がわかる
k = []
7.times do |i|
    k[i] = calc_key(C[i], P[i])
end


puts "p: #{P} (#{P.size} characters)"
puts "c: #{C} (#{C.size} characters)"
puts "k: #{k} (#{k.size} characters)"

# 最後もわかる
puts "the 43rd elememnt of the key: #{calc_key(C[-1], P[-1])}"

# p: SECCON{???????????????????????????????????} (43 characters)
# c: LMIG}RPEDOEEWKJIQIWKJWMNDTSR}TFVUFWYOCBAJBQ (43 characters)
# k: ["V", "I", "G", "E", "N", "E", "R", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "R"] (43 characters)
# the 43rd elememnt of the key: R


# VIGENER... 8 番目は E ?
k[7] = 'E'

## # 43 番目に R が来るように…うーん，もう少しヒントほしい…
## # カシスキー・テスト やってみるか
## class String
##     def ngram(n)
##         characters = self.split(//u)
##         return [self] if characters.size <= n
##         return characters.each_cons(n).collect(&:join)
##     end
## end
##
## puts C.ngram(3).inject(Hash.new(0)){|r, i| r[i] += 1; r}
## # {"LMI"=>1, "MIG"=>1, "IG}"=>1, "G}R"=>1, "}RP"=>1, "RPE"=>1, "PED"=>1, "EDO"=>1, "DOE"=>1, "OEE"=>1, "EEW"=>1, "EWK"=>1, "WKJ"=>2, "KJI"=>1, "JIQ"=>1, "IQI"=>1, "QIW"=>1, "IWK"=>1, "KJW"=>1, "JWM"=>1, "WMN"=>1, "MND"=>1, "NDT"=>1, "DTS"=>1, "TSR"=>1, "SR}"=>1, "R}T"=>1, "}TF"=>1, "TFV"=>1, "FVU"=>1, "VUF"=>1, "UFW"=>1, "FWY"=>1, "WYO"=>1, "YOC"=>1, "OCB"=>1, "CBA"=>1, "BAJ"=>1, "AJB"=>1, "JBQ"=>1}
##
## # WKJ が 2 回出てる！
## # と思ったら，
## # C = "LMIG}RPEDOEEWKJIQIWKJWMNDTSR}TFVUFWYOCBAJBQ"
## # だと， 13 番目と 19 番目 (近すぎ…)

def decrypt(c, k)
    TABLE[(TABLE.index(c) - TABLE.index(k) + TABLE.size) % TABLE.size]
end


MD5 = "f528a6ab914c1ecf856a1d93103948fe"

def test(k)
    ans = []
    C.each_char.with_index do |c, i|
        ans << decrypt(c, k[i % k.size])
    end
    ans = ans.join()

    ans_md5 = Digest::MD5.hexdigest(ans)
    if ans_md5 == MD5
        puts "OK!"
        puts "ans: #{ans}"
        puts "(key: #{k})"
        return true
    end
    return false
end

# 総当りするよ…
TABLE.split("").repeated_permutation(4) do |a0,a1,a2,a3|
    k[8] = a0
    k[9] = a1
    k[10] = a2
    k[11] = a3
    exit if test(k)
end

puts "NG"

# OK!
# ans: SECCON{ABABABCDEDEFGHIJJKLMNOPQRSTTUVWXYYZ}
# (key: ["V", "I", "G", "E", "N", "E", "R", "E", "C", "O", "D", "E"])
