def translated(word)
  / (?<middle>        # group 1; matches all consonants up to the
                      #   first vowel, also matching 'qu' if it's there
      [^aeiou]*?qu    # matches zero or more consonants followed by 'qu'
      |
      [^aeiou]*       # if no 'qu', match zero or more consonants 
    )
    (?<front>.*)      # match everything that comes after the 'middle' group
  /x =~ word
  front << middle << 'ay'
end

def translate(string)
  string.scan(/(\S*?)(\w+)(\S*)/).map! do |before, word, after|
    # is the word capitalized?
    capitalized = word[0] == word[0].upcase
    word.downcase!

    # translate the word
    word = translated word

    # need to capitalize?
    word[0] = word[0].upcase! if capitalized

    # Finally, recombine with before and after. This strategy allows us to
    # deal with corner cases like punctuation and 's.
    before << word << after
  end
  .join(' ')
end