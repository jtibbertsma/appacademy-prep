def echo(string)
  string
end

def shout(string)
  string.upcase
end

def repeat(string, rep=2)
  fail "Bad repeat number" if rep <= 0
  rep.times.map { string }.join(' ')
end

def start_of_word(string, num)
  string[0, num]
end

def first_word(string)
  string.split[0]
end

def titleize(string)
  little_words = %w{ and over the a an in of }
  string.split.each_with_index.map do |word, n|
    word[0] = word[0].upcase unless n > 0 && little_words.include?(word)
    word
  end
  .join(' ')
end
