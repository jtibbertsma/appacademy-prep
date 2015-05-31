class Fixnum
  
  private
  
  def convert_less_hundred(num)
    if num < 10
      Ones[num]
    elsif num < 20
      Teens[num % 10]
    else
      Tens[num / 10] + ' ' + Ones[num % 10]
    end
  end
  
  def convert_less_thousand(num)
    if num < 100
      convert_less_hundred(num)
    else
      Ones[num / 100] + " hundred " + convert_less_hundred(num % 100)
    end
  end
    
  def divide_into_groups(string) #Will return groups in reverse order
    matches = string.reverse.scan(/\d\d?\d?/)
    matches.map { |string| string.reverse.to_i }
  end
  
  Ones = %w{one two three four five six seven eight nine}.unshift("")
  Teens = %w{ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen}
  Tens = %w{zero ten twenty thirty forty fifty sixty seventy eighty ninety}
  Ions = %w{thousand million billion trillion quadrillion}.unshift("")
  
  public
  
  def in_words
    return 'zero' if self == 0
    words = ""
    in_threes = divide_into_groups(self.to_s)
    in_threes.each_with_index do |group, index|
      if group > 0
        words = convert_less_thousand(group) + " " + Ions[index] + " " + words
      end
    end
    words.gsub!(/\s+/, ' ')
    words.gsub!(/\s+$/,"")
  end
end