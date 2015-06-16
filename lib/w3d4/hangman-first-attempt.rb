require 'byebug'

class Player
  attr_reader :errors, :secret_word_display, :secret_word
  
  def initialize
    get_dictionary
    @seen_chars = []
    @errors = 10
  end
  
  def get_secret_word
    @secret_word = @dictionary.sample
  end

  def decrement_error_count
    @errors -= 1
    puts "Bad choice; try again"
  end
    
  def get_dictionary
    @dictionary = File.read('dictionary.txt').split
  end
  
end

class HumanPlayer < Player

  attr_reader :secret_word_display, :secret_word
  
  def initialize
    super
    get_secret_word
    @secret_word_display = "_" * @secret_word.length
  end
  
  def change_characters(secret_word, input)
    @secret_word.each_char.each_with_index do |char, index|
      if input == char
        @secret_word_display[index] = char
      end
    end
  end
  
  def get_secret_word
    @secret_word = @dictionary.sample
  end
  
  def word_includes?(input)
    @secret_word.include?(input)
  end
  
  def get_input
    puts "You have #{@errors} guesses left"
    puts @secret_word_display
    puts
    print "Enter a letter: "
    input = gets.chomp.downcase
    return get_input unless valid?(input)
    @seen_chars << input
    input
  end
  
  def valid?(input)
    if @seen_chars.include?(input)
        puts "you've already tried that letter"
        return false
    elsif input.length == 1 && input =~ /[a-z]/
      return true
    else
      puts "invalid entry"
      return false
    end
  end      
  
  # def change_characters(secret_word, input)
  #   @secret_word.each_char.each_with_index do |char, index|
  #     if input == char
  #       @secret_word_display[index] = char
  #     end
  #   end
  # end

  # def decrement_error_count
  #   @errors -= 1
  #   puts "Bad choice; try again"
  # end
    
  # def get_dictionary
  #   @dictionary = File.read('dictionary.txt').split
  # end

end


class ComputerPlayer < Player
  
  def initialize(length)
    super()
    @regression = @dictionary.select { |word| word.length == length }
    @secret_word_display = '_' * length
  end

  def get_input
    letter_count = Hash.new { |hash, item| hash[item] = 0 }
    @regression.each do |word|
      word.each_char do |char|
        letter_count[char] += 1
      end 
    end
    @seen_chars.each { |char| letter_count.delete(char) }
    res = letter_count.max { |a, b| a[1] <=> b[1] }.first
    @seen_chars << res
    return res
  end 
  
  def word_includes?(input)
    #print something out and enter which indeces are correct
    puts "does the word include the letter #{input}? true/false"
    answer = gets.chomp
    if answer == "true"
      return true
    elsif answer == "false"
      return false
      regression_no_match(input)
    else
      puts "this is only a true/false sort of question"
      word_includes?(input)
    end
  end
    
  def change_characters(secret_word, input)
    puts @secret_word_display
    puts "which indices can be changed to the letter? (x y)"
    @change_indeces = gets.scan(/\d+/).map(&:to_i)
    @change_indeces.each do |i|
      secret_word_display[i] = input
    end
    puts @secret_word_display
    regeression_match(input)
  end
  
  def regeression_match(input)
    #scans for only words that include the input
    @regression.select! do |word|
      word_matches?(word, input, @change_indeces)
    end
        
  end
  
  def word_matches?(word, input, change_indeces)
    change_indeces.each do |i|
      if word[i] != input
        return false
      end 
    end 
    true
  end
  

  def regression_no_match(input)
    #deletes all words that include the input
    @regression.select! do |word|
      !word.include? input
    end
  end

end

class Game
  
  attr_reader :dictionary
  
  def initialize(player)
    @player = player
    @secret_word = @player.secret_word
  end
  
  def play
    while @player.errors > 0 && !solved?
      input = @player.get_input
      if @player.word_includes?(input)
        @player.change_characters(@secret_word, input)
      else
        @player.decrement_error_count
      end
    end
    if @player.errors == 0
      puts "You've run out of guesses! Sorry, the word was #{@secret_word}."
    end
  end
  

  
  
  def solved?
    if !@player.secret_word_display.include?("_")
      puts @player.secret_word_display
      puts "You've solved the game!"
      return true
    else
      false
    end
  end
  
  
end

player = (ComputerPlayer.new(6))

Game.new(player).play


# computer gets length of secret word from human player
# computer guesses most common letter from words in dictionary of that length
# human player indicates if guess is valid, chooses placement in secret word display
# computer does regression on dictionary, and chooses most common letter from remaining words
