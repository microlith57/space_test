module Yleta
  VOWELS = {"a" => "ä", "i" => "ï", "o" => "ö", "y" => "ÿ"}

  def self.adultspeak(childspeak : String)
    ch = childspeak

    case childspeak.size
    when 2 then return ch[1].to_s + ch[0]
    when 6 then return adultspeak(ch[0..2]) + adultspeak(ch[2..6])
    when 8
      str = adultspeak(ch[0..4]) + adultspeak(ch[4..8])
      return str.gsub("aa", "ä").gsub("ii", "ï").gsub("oo", "ö").gsub("yy", "ÿ")
    else
      c1 = (ch[0]? || "").to_s
      v1 = (ch[1]? || "").to_s
      c2 = (ch[2]? || "").to_s
      v2 = (ch[3]? || "").to_s

      # lili -> lï
      if c1 == c2 && v1 == v2
        return VOWELS[v1] + c1
      end

      # lila -> lia
      if c1 == c2
        return v1 + c1 + v2
      end

      # kala -> käl
      if v1 == v2
        return VOWELS[v1] + c1 + "e" + c2
      end

      return v1 + c1 + "e" + c2 + v2
    end
  end
end
