
class Game

Rules = %(The game is Mastermind.

The goal is to choose the correct sequence of colors. Your choices are:

  R (for red)
  G (for green)
  B (for blue)
  Y (for yellow)
  O (for orange)
  P (for purple)

Every turn, you will type in a sequence, and the computer will tell you
your number of exact matches (meaning you have a correct color in the
correct position), and near matches (meaning you have a correct color
in the wrong position).

Example:

  If the correct code is RBGB and you guess GBYO, the computer will
  print

  Exact matches: 1
  Near matches:  1

)

  def self.play
    Game.new.play
  end

  attr_accessor :answer, :tries

  def initialize(options = {})
    @tries = options[:tries] || 10
    @answer = Code.parse(options[:answer]) || Code.random
    @input_attempts = 0
  end

  def play
    puts Rules
    tries.downto(1) do |n|
      puts tries_left(n)
      do_one_turn { return }
    end
    lose
  end

  def do_one_turn
    input = get_input_from_user
    guess = Code.parse(input)

    if (num_correct = answer.exact_matches(guess)) == 4
      win { yield if block_given?; return }
    end

    puts
    puts "Exact matches: #{num_correct}"
    puts "Near matches:  #{answer.near_matches(guess)}"
    puts
  end

  private
  def tries_left(n)
    "You have #{n} #{n == 1 ? 'try' : 'tries'} left"
  end

  def win
    puts "Congratulations! You win!"
    yield
  end

  def lose
    puts "You are a LOSER!"
    puts "The code you were looking for was #{answer}"
  end

  def get_input_from_user
    code = loop do
      print prompt
      input = gets
      break input if valid?(input)
    end

    reset!
    code
  end

  def gets
    @input_attempts += 1
    unless code = STDIN.gets
      puts; exit
    end
    code.chomp!
    code.upcase!
    code
  end

  def valid?(code)
    bad_colors, bad_length = bad_colors?(code), bad_length?(code)
    if bad_colors || bad_length
      puts
      false
    else
      true
    end
  end

  def bad_length?(code)
    if code.length != 4
      puts "Expected 4 characters; got #{code.length}"
      true
    else
      false
    end
  end

  def bad_colors?(code)
    if !(bad_colors = code.scan(color_regex).uniq).empty?
      puts "Invalid colors: #{bad_colors.join(', ')}"
      true
    else
      false
    end
  end

  def color_regex
    @cr ||= /[^#{Code::Colors.join}]/
  end

  def prompt
    @input_attempts == 0 ? "Enter a four letter code: "
                         : "Please try again: "
  end

  def reset!
    @input_attempts = 0
  end
end

class Code
  Colors = %w(R G B Y O P)

  def self.random
    colors = ''
    4.times { |n| colors << Colors.sample }
    Code.new(colors)
  end

  def self.parse(input)
    return nil if input.nil?
    Code.new(input)
  end

  attr_reader :colors

  def initialize(colors)
    @colors = colors.upcase
  end

  def exact_matches(other)
    count_matches(other) { |a, b| a == b }
  end

  def near_matches(other)
    count_matches(other) { |a, b| a != b && colors.include?(b) }
  end

  def to_s
    colors
  end

  private
  def count_matches(other)
    4.times.inject(0) do |match_count, n|
      yield(colors[n], other.colors[n]) ? match_count + 1 : match_count
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Game.play
end