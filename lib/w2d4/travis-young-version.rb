

class Game

  def initialize(n = 3)
    @board = Board.new(n)
    @n = n
    puts 'Watch, CPU, 2-Player? ("w", "c" or "2")'
    game_type = gets.chomp

    if game_type == "w"
      @player1 = ComputerPlayer.new("X")
      @player2 = ComputerPlayer.new("O")
    elsif game_type == "c"
      puts "Would you like to be player1? (Y,N)"
      resp = gets.chomp
        if resp == "N"
          @player1 = HumanPlayer.new("X")
          @player2 = ComputerPlayer.new("O")
        else
          @player1 = ComputerPlayer.new("X")
          @player2 = HumanPlayer.new("O")
        end
      else
        @player1 = HumanPlayer.new("X")
        @player2 = HumanPlayer.new("O")
      end
      play
    end

    def play
      num_moves = 0
      until @board.won? || num_moves == @n * @n do
        @board.show_board
        @player1.move(@board)
        num_moves += 1
        if @board.won? || num_moves == @n * @n
          break
        end
        @board.show_board
        @player2.move(@board)
        num_moves += 1
      end

      @board.show_board
      if @board.won?
        puts "#{@board.winner} is winner!"
      else
        puts "Draw!"
      end
    end

    def board
      @board
    end

end

class Board

#X is assigned 1 and O is assigned -1. An entry on the board for a player
#is the assigned number. In this model, a win is equivalent to an "axis" (row, column, diagonal)
#whose entries sum to @n or -@n. We can check whether there is such an axis in constant time with @axes_for_sum
#a value in @axes_for_sum for key, k represnets the axes that sum to k. E.g.
#{ 0 => { :row => { 0 => true, 1 => true, 2 => true }, :col => { 0 => true , 1 => true, 2 => true }, d: => { 0 => true , 1 => true } } }
#represents the initial board configuration.
#Although this nested structure seems cumbersome, it allows for constant-time updating of which sums correspaond to which rows.
#The updating will be done in Board#[]=(row, col, player)

  def initialize(n = 3)
    @n = n
    @grid = Array.new(n, Array.new(n, nil))
    @row_sums = Array.new(n, 0)
    @col_sums = Array.new(n, 0)
    @diag_sums = [0, 0]
    @axes_for_sum = {}
    @axes_for_sum[0] = [[:row, (0...@n).map {|i| [i, true]}.to_h], [:col, (0...@n).map {|i| [i, true]}.to_h], [:d, {0 => true, 1 => true}]].to_h
    @xORo_hash = { "X" => 1, "O" => -1 }
  end

  def n
    @n
  end

  def grid
    @grid
  end

  def rows
    @row_sums
  end

  def cols
    @col_sums
  end

  def diags
    @diag_sums
  end

  def axes_for_sum
    @axes_for_sum
  end

  def xORo_hash
    @xORo_hash
  end


  def [](row, col)
    @grid[row][col]
  end

  def empty?(row, col)
    !self[row, col]
  end

  def update_row(row, player)
    prev_row_sum = @row_sums[row]
    @row_sums[row] += @xORo_hash[player]
    row_sum = @row_sums[row]

    #asscoiate the current sum with this axis
    #O(1) runtime
    if @axes_for_sum[row_sum]
      if @axes_for_sum[row_sum][:row]
        @axes_for_sum[row_sum][:row][row] = true
      else
        @axes_for_sum[row_sum][:row] = { row => true }
      end
    else
      @axes_for_sum[row_sum] = { :row => { row => true } }
    end
    #UNassociate the previous sum with this axis
    #O(1) runtime
    @axes_for_sum[prev_row_sum][:row][row] = false
  end

  def update_col(col, player)
    prev_col_sum = @col_sums[col]
    @col_sums[col] += @xORo_hash[player]
    col_sum = @col_sums[col]

    if @axes_for_sum[col_sum]
      if @axes_for_sum[col_sum][:col]
        @axes_for_sum[col_sum][:col][col] = true
      else
        @axes_for_sum[col_sum][:col] = { col => true }
      end
    else
      @axes_for_sum[col_sum] = { :col => { col => true } }
    end
    @axes_for_sum[prev_col_sum][:col][col] = false
  end

  def update_diag(d, player)

    if d == 0
      prev_diag0_sum = @diag_sums[0]
      @diag_sums[0] += @xORo_hash[player]
      diag0_sum = @diag_sums[0]
      if @axes_for_sum[diag0_sum]
        if @axes_for_sum[diag0_sum][:d]
          @axes_for_sum[diag0_sum][:d][0] = true
        else
          @axes_for_sum[diag0_sum][:d] = { 0 => true }
        end
      else
        @axes_for_sum[diag0_sum] = { :d => { 0 => true } }
      end
      @axes_for_sum[prev_diag0_sum][:d][0] = false
    else
      prev_diag1_sum = @diag_sums[1]
      @diag_sums[1] += @xORo_hash[player]
      diag1_sum = @diag_sums[1]
      if @axes_for_sum[diag1_sum]
        if @axes_for_sum[diag1_sum][:d]
          @axes_for_sum[diag1_sum][:d][1] = true
        else
          @axes_for_sum[diag1_sum][:d] = { 1 => true }
        end
      else
        @axes_for_sum[diag1_sum] = { :d => { 1 => true } }
      end
      @axes_for_sum[prev_diag1_sum][:d][1] = false
    end
  end

  def []=(row, col, player)
    r = @grid[row].map {|el| el}
    r[col] = player
    @grid[row] = r

    update_row(row, player)
    update_col(col, player)
    update_diag(0, player) if row == col
    update_diag(1, player) if row + col == @n - 1
  end

  # O(1) runtime
  def won?
    @axes_for_sum[@n] || @axes_for_sum[-@n]
  end

  # O(1) runtime
  def winner
    @axes_for_sum[@n] ? "X" : "O"
  end

  def show_board
    space = (20 / @n - 1) / 2
    (0...@n).each do |i|
      puts @grid[i].map { |value| "#{" " * space}#{value ? value : " "}#{(" " * space)}"}.join("|")
      unless i == @n - 1
        puts "-" * 20
      end
    end
    5.times {|i| puts}
  end

end

class Player

  def initialize(xORo)
    @xORo = xORo
  end

  def xORo
    @xORo
  end

  def move(board)
    move = Logic.new(board, self).get_move
    board[*move] = @xORo
  end
end

class ComputerPlayer < Player
end

class HumanPlayer < Player
end

class Logic
  def initialize(board, player)
    @board = board
    @player = player
  end

  def get_move
    if @player.class == ComputerPlayer
      ai
    else
      puts "#{@player.xORo}'s move"
      puts 'Enter: "<row>,<col>"'
      gets.chomp.split(",").map {|c| c.to_i}
    end
  end

    #ai can easily be modified to check for impending losses as well
  def ai
    axes_for_win = @board.axes_for_sum[(@board.n - 1) * @board.xORo_hash[@player.xORo]]
    move = nil
    pos = nil
    if axes_for_win
      [:row, :col, :d].each do |type|
        if move
          break
        end
        if axes_for_win[type]
          axes_for_win[type].each do |axis, present|
            if present
              move = [type, axis]
              break
            end
          end
        end
      end
    end

    if move
      if move == :row
        (0...@board.n).each do |i|
          if @board.empty?(move[1], i)
            pos = [move[1], i]
            break
          end
        end
      elsif move[0] == :col
        (0...@board.n).each do |i|
          if @board.empty?(i, move[1])
            pos = [i, move[1]]
            break
          end
        end
      elsif move[1] == 0
        (0...@board.n).each do |i|
          if @board.empty?(i, i)
            pos = [i, i]
            break
          end
        end
      else
        (0...@board.n).each do |i|
          if @board.empty?(i, @board.n - i - 1)
            pos = [i, @board.n - i - 1]
          end
        end
      end
      pos
    else
      possible_pos = []
      (0...@board.n).each do |i|
        (0...@board.n).each do |j|
          if @board.empty?(i, j)
            possible_pos << [i, j]
          end
        end
      end
      pos = possible_pos.sample
    end
    pos
  end


end
