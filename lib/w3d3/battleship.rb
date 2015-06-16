require 'byebug'

class Game
  attr_reader :board, :turns, :player

  def initialize(turns = 40)
    @turns = turns
    @board = Board.populated_board
    @player = HumanPlayer.new(board)
  end

  def play
    turns.downto(1) do |missles_remaining|
      player.execute_move(missles_remaining)
    end
    
  end
end

class Board
  def self.populated_board
    board = Board.new
    board.populate!
    board
  end

  attr_reader :grid, :ships
  attr_accessor :stretch_factor

  def initialize
    @grid = Array.new(10) do
      Array.new(10) { :nothing }
    end
    @stretch_factor = 5
  end

  def populate!
    ship_sizes.each do |size|
      place_random_ship! size
    end
  end

  def [](i, j)
    @grid[i][j]
  end

  def []=(i, j, symbol)
    @grid[i][j] = symbol
  end

  def display(options = {})
    show_ships = options[:show_ships]
    top_labels

    letter_A = 65
    10.times do |n|
      puts
      print " #{(n + letter_A).chr}"
      print_row(grid[n], show_ships)
    end
  end

  private
  def top_labels
    print '  '
    1.upto(10) do |i|
      print format("%#{stretch_factor}d", i)
    end
    puts
  end

  def print_row(row, show_ships)
    row.each do |contents|
      case contents
      when :nothing
        mark = '.'
      when :hit
        mark = '*'
      when :miss
        mark = '/'
      when :ship
        mark = show_ships ? '#' : '.'
      end
      print format("%#{stretch_factor}s", mark)
    end
    puts
  end

  def ship_sizes
    [2, 2, 3, 3, 4, 5]
  end

  def place_random_ship!(size)
    ship = loop do
      cell = get_random_empty_cell
      orientation = [:vertical, :horizontal].sample
      ship = get_ship_cells(size, cell, orientation)
      break ship unless conflict?(ship)
    end
    place_ship! ship
  end

  def get_ship_cells(size, cell, orientation)
    i, j = cell
    j = [10 - size, j].min

    cells = size.times.map { |n| [i, j + n] }
    cells.each { |cell| cell.reverse! } if orientation == :vertical
    cells
  end

  def place_ship!(ship)
    ship.each { |cell| self[*cell] = :ship }
  end

  def get_random_cell
    [rand(10), rand(10)]
  end

  def get_random_empty_cell
    loop do
      cell = get_random_cell
      break cell if self[*cell] == :nothing
    end
  end

  def conflict?(cells)
    cells.each { |cell| return true unless self[*cell] == :nothing }
    false
  end
end

Game.new.play