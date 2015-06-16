# Tic-Tac-Toe

# Let's write a Tic-Tac-Toe game!

# You should have a Board class and a Game class. The board should have methods 
#   like #won?, winner, empty?(pos), place_mark(pos, mark), etc.
# The Game class should have a play method that loops, reading in user moves. 
#   When the game is over, exit the loop.
# You should have a class that represents a human player (HumanPlayer), and 
#   another class for a computer player (ComputerPlayer). Start with the human
#   player first.
# Both HumanPlayer and ComputerPlayer should have the same API; they should have 
#   the same set of public methods. This means they should be interchangeable.
# Your Game class should be passed two player objects on instantiation; because 
#   both player classes have the same API, the game should not know nor care what 
#   kind of players it is given.
# Keep the computer AI simple: make a winning move if available; else move randomly.
# Get a TA to review your work and make suggestions!

class Board
  
  attr_accessor :board

  def initialize
    @board = Array.new(4) { Array.new(4) { ' ' } }
    @board[0][1] = "1"
    @board[0][2] = "2"
    @board[0][3] = "3"
    @board[1][0] = "A"
    @board[2][0] = "B"
    @board[3][0] = "C"
  end

  def [](row, col)
    @board[row][col]
  end

  def []=(row, col, mark)
    @board[row][col] = mark
  end
  
  def display_board
    @board.each do |row|
      p row
    end
  end 
  
  def won?
    (1..3).each do |i|
      return true if check_row(i)
      return true if check_col(i)
    end
    
    return true if positions_equal?(self[1, 1], self[2, 2], self[3, 3])
    return true if positions_equal?(self[1, 3], self[2, 2], self[3, 1])
  end 
  
  def check_col(i)
    return true if positions_equal?(self[1, i], self[2, i], self[3, i]) 
  end 
  
  def check_row(i)
    return true if positions_equal?(self[i, 1], self[i, 2], self[i, 3])
  end
  
  def positions_equal?(*args)
    # args.each do |i, j|
    #   return false if self[i,j] == " "
    # end 
    
    return false if args.any? { |i,j| @board[i][j] == ' ' }
    item = args[0]
    args[1,args.length-1].each do |other_item|
      return false if item != other_item
    end
    true
  end
  
  def get_winning_move
    return [2,2] if self[2,2] == ' ' && check_2_2
    (1..3).each do |i|
      (1..3).each do |j|
        next if @board[i][j] != ' '
        return [i,j] if positions_equal?(*others_in_col(i,j))
        return [i,j] if positions_equal?(*others_in_row(i,j))
        if is_diagonal?(i,j)
          return [i,j] if positions_equal?(*others_in_diagonal(i,j))
        end
      end
    end
    nil
  end
  
  def check_2_2
    positions_equal?([1,1],[3,3]) || positions_equal?([1,3],[3,1])
  end
  
  def others_in_row(i,j)
    arr = []
    (1..3).each do |k|
      arr << [i, k] if k != j
    end 
    arr
  end
  
  def others_in_col(i,j)
    arr = []
    (1..3).each do |k|
      arr << [k, j] if k != i
    end
    arr
  end
  
  def others_in_diagonal(*pos)
    hash = {[1,1] => [[2,2], [3,3]],
            [3,3] => [[2,2], [1,1]],
            [1,3] => [[2,2], [3,1]],
            [3,1] => [[2,2], [1,3]]}
    hash[pos]
  end
  
  def is_diagonal?(*pos)
    [[1,1], [1,3], [3,1], [3,3]].include?(pos)
  end
  
end


class Game
  def self.run
    board = Board.new
    Game.new(HumanPlayer.new(board), ComputerPlayer.new(board), board).play
  end
  
  def initialize(player1, player2, board)
    @player1 = player1
    @player2 = player2
    @board = board
    @steps = 0
  end
  
  def get_move_from_player(player, mark)
    mv = player.get_move
    p mv
    @board[*mv] = mark
    @steps += 1
    @board.display_board
    return nil if @steps >= 5 && (@board.won? || @steps == 9)
    return 0
  end 
  
  def play
    loop do
      break if get_move_from_player(@player1, "X").nil?
      break if get_move_from_player(@player2, "O").nil?
    end
    puts "Congrats!"
  end
end

class Player
  attr_accessor :board
  
  def initialize(board)
    @board = board
  end
end

class HumanPlayer < Player
  def get_move
    print "Please enter a move: "
    input = gets.chomp.downcase
    letter = input.scan(/^[a-c]|[a-c]$/)[0]
    number = input.scan(/^[1-3]|[1-3]$/)[0]
    return get_move if !letter || !number
    [letter.ord-96, number.to_i]
  end 
  
end

class ComputerPlayer < Player
  def get_move
    win = board.get_winning_move
    return win unless win.nil?
    
    possible_moves = []
    (1..3).each do |i|
      (1..3).each do |j|
        possible_moves << [i, j] if board[i, j] == " "
      end 
    end
    possible_moves.shuffle[0]
  end 
  
end

Game.run
