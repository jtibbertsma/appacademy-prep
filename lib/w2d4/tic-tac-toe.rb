require 'optparse'
require 'byebug'

require_relative './option-specification'

module GameClassMethods
  def run
    options = parse_options
    board = instantiate_board(options)
    players = instantiate_players(options, board)
    game = Game.new(board, players)

    game.play
  end

  def instantiate_board(options)
    board = Board.new(options[:board_size] || 3)

    if sf = options[:stretch_factor]
      board.stretch_factor = sf
    end

    if p = options[:padding]
      board.padding = p
    end

    board
  end

  def instantiate_players(options, board)
    case options[:game_type]
    when :human_vs_computer
      initiate_human_vs_computer(options, board)
    when :human_vs_human
      initiate_human_vs_human(options, board)
    when :computer_vs_computer
      initiate_computer_vs_computer(options, board)
    else
      fail "unknown game type"
    end
  end

  def initiate_human_vs_computer(options, board)
    mark1 = options[:o_goes_first] ^ options[:go_second] ? :O : :X
    mark2 = mark1 == :O ? :X : :O
    players = [
      instantiate_human(options, 1, mark1, board),
      instantiate_computer(options, nil, mark2, board)
    ]
    players.reverse! if options[:go_second]
    players
  end

  def initiate_human_vs_human(options, board)
    initiate_same_type(options, board, :instantiate_human)
  end

  def initiate_computer_vs_computer(options, board)
    initiate_same_type(options, board, :instantiate_computer)
  end

  def initiate_same_type(options, board, symbol)
    mark1 = options[:o_goes_first] ? :O : :X
    mark2 = mark1 == :O ? :X : :O
    [send(symbol, options, 1, mark1, board),
     send(symbol, options, 2, mark2, board)]
  end

  def instantiate_human(options, *args)
    human = HumanPlayer.new(*args)
    if name = options[:names].shift
      human.name = name
    end
    human
  end

  def instantiate_computer(options, *args)
    comp = ComputerPlayer.new(*args)

    if difficulty = options[:difficulty].shift
      comp.difficulty = difficulty
    end

    unless options[:humans_only]
      if name = options[:names].shift
        comp.name = name
      end
    end

    comp.print_board = options[:print_board]
    comp
  end

  def parse_options
    option_hash = default_options
    parser = option_specification(option_hash)

    begin
      parse_options_from_command_line(option_hash, parser)
      parse_options_from_config_file(option_hash, parser)
    rescue OptionParser::ParseError => e
      puts e
      exit
    end

    option_hash
  end

  def default_options
    {:difficulty => [],
     :names      => [],
     :game_type  => :human_vs_computer}
  end

  def parse_options_from_command_line(_, parser)
    parser.parse(ARGV)
  end

  def parse_options_from_config_file(options, parser)
    if filename = options[:config_file]
      merge_options(options) do
        handle_config_file(filename, parser)
      end
    else
      filename = File.expand_path(".tic-tac-toe", File.dirname(__FILE__))
      merge_options(options) do
        handle_config_file(filename, parser) if File.exist?(filename)
      end
    end
  end

  def handle_config_file(filename, parser)
    args = File.foreach(filename).map { |str| str.split(',') }
    args.flatten!
    parser.parse(args)
  end

  def merge_options(options)
    command_line = options.clone
    options.clear
    options.merge!(default_options)
    yield
    delete_unchanged_defaults(command_line)
    options.merge!(command_line)
  end

  def delete_unchanged_defaults(options)
    default_options.each do |key, value|
      options.delete(key) if value == options[key]
    end
  end
end

class Game
  extend GameClassMethods

  attr_reader :board, :players

  def initialize(board, players)
    @board   = board
    @players = players
    @next    = 0
  end

  def play
    until board.game_over?
      move = next_player.get_move
      move.execute
    end

    puts board
    puts
    puts end_message
  end

  private
  def next_player
    next_player = players[@next]
    @next = @next == 0 ? 1 : 0
    next_player
  end

  def end_message
    case board.winner
    when :draw
      "Draw, try again..."
    when :O
      player_message :O
    when :X
      player_message :X
    else
      fail "unknown winner symbol"
    end
  end

  def player_message(mark)
    players.each do |player|
      return "#{player.name} wins!" if player.mark == mark
    end
    fail "reached end of #player_message"
  end
end

module BoardPrinter
  attr_accessor :stretch_factor, :padding

  def initialize
    @stretch_factor = 9
    @padding = 0
  end

  def render
    lines = []
    dead_row = Array.new(size) { ' ' }

    lines << top_labels

    1.upto(size) do |n|
      lines << build_row(' ', dead_row)
      lines << build_row(n, @grid[n-1])
      lines << build_row(' ', dead_row)
      lines << dashes if n < size
    end

    lines.join("\n")
  end

  private
  def top_labels
    letter = 65
    x = ' ' * ((stretch_factor - 1) / 2)
    chunks = []

    size.times do
      chunks << x + "#{letter.chr}" + x
      letter += 1
    end

    (' ' * padding) << (' ' * 2) << chunks.join(' ')
  end

  def build_row(label, marks)
    chunks = []
    x = ' ' * ((stretch_factor - 1) / 2)

    marks.each do |mark|
      chunks << x + "#{mark}" + x
    end

    (' ' * padding) << "#{label}" << (' ' * 1) << chunks.join('|')
  end

  def dashes
    chunks = []

    size.times do
      chunks << '-' * stretch_factor
    end

    (' ' * padding) << (' ' * 2) << chunks.join('|')
  end
end

module BoardSearchingLogic
  private
  def game_over_logic
    return false if num_filled < size * 2 - 1

    return true if check_rows_for_winner
    return true if check_cols_for_winner
    return true if check_diag_for_winner
    return true if check_for_draw

    false
  end

  def check_rows_for_winner
    array_win_check(@grid)
  end

  def check_cols_for_winner
    cols = size.times.map do |j|
      size.times.map do |i|
        @grid[i][j]
      end
    end
    array_win_check(cols)
  end

  def check_diag_for_winner
    one = size.times.map { |i| @grid[i][i] }

    j = size
    two = size.times.map do |i|
      j -= 1
      @grid[i][j]
    end

    array_win_check([one, two])
  end

  def check_for_draw
    if num_filled == size*size
      @winner = :draw
      true
    else
      false
    end
  end

  def array_win_check(arrays)
    arrays.each do |array|
      if sym = get_symbol_from_completed_array(array)
        @winner = sym
        return true
      end
    end
    false
  end

  def get_symbol_from_completed_array(array)
    array.first if array_complete?(array)
  end

  def array_complete?(array)
    return false if array.any? { |item| item == ' ' }
    array.uniq.length == 1
  end

  def vital_cells_logic
    res = Hash.new { |hash, key| hash[key] = [] }
    available_cells.each do |cell|
      cell_relation_map[cell].each do |relation|
        relation = map_indices_to_elements(relation)
        sym = get_symbol_from_completed_array(relation)
        res[cell] << sym if sym
      end
    end
    res
  end

  def map_indices_to_elements(array)
    array.map { |cell| self[*cell] }
  end

  def cell_relation_map
    @crm ||= build_cell_relation_map
  end

  def build_cell_relation_map
    crm = Hash.new { |hash, key| hash[key] = [] }
    size.times.each do |i|
      size.times.each do |j|
        build_portion_for_given_cell([i, j], crm)
      end
    end
    crm
  end

  def build_portion_for_given_cell(index, hash)
    build_portion_row(index, hash)
    build_portion_col(index, hash)
    build_portion_diag(index, hash)
  end

  def build_portion_row(index, hash)
    i, j = index
    build_relation_chunk(index, hash) { |n| [i, n] if n != j }
  end

  def build_portion_col(index, hash)
    i, j = index
    build_relation_chunk(index, hash) { |n| [n, j] if n != i }
  end

  def build_portion_diag(index, hash)
    i, j = index

    if i == j
      build_relation_chunk(index, hash) { |n| [n, n] if n != i }
    end

    if i + j == size - 1
      build_relation_chunk(index, hash) { |n| [n, size - 1 - n] if n != i }
    end
  end

  def build_relation_chunk(index, hash, &block)
    hash[index] << size.times.map(&block).select! { |item| item }
  end
end

class Board
  include BoardPrinter
  include BoardSearchingLogic

  attr_reader :size, :winner, :num_filled

  def initialize(size = 3)
    fail "Error: board must be at least 3x3;" +
        " no more than 9x9; #{size} given" if size < 3 || size > 9
    super()
    @size = size
    @num_filled = 0
    @grid = Array.new(size) do
      Array.new(size) { ' ' }
    end
  end

  def [](i, j)
    @grid[i][j]
  end

  def []=(i, j, mark)
    fail "Overwriting mark" unless available?(i, j)
    @grid[i][j] = mark
    @num_filled += 1
  end

  def to_s
    render
  end

  def game_over?
    game_over_logic
  end

  def available?(*cell)
    self[*cell] == ' '
  end

  def available_cells
    ar = []
    size.times do |i|
      size.times do |j|
        ar << [i, j] if available?(i, j)
      end
    end
    ar
  end

  def vital_cells
    (vital_cells_logic if num_filled >= size * 2 - 3) || {}
  end
end

class Move < Struct.new(:board, :cell, :mark)
  def execute
    board[*cell] = mark
  end
end

class Player
  attr_accessor :mark, :board, :name

  def initialize(number, mark, board)
    @mark  = mark
    @board = board
  end

  private
  def get_random_empty_cell
    board.available_cells.sample
  end

  def get_vital_cell(priority_mark = nil)
    priority_mark ||= [:X, :O].sample
    res = nil
    board.vital_cells.to_a.shuffle!.each do |cell, marks|
      return cell if marks.include?(priority_mark)
      res = cell
    end
    res
  end

  def valid?(input)
    return false if input.nil?
    i, j = input
    return false if i < 0 || i >= board.size || j < 0 || j >= board.size
    board.available?(i, j)
  end
end

class HumanPlayer < Player
  def initialize(number, mark, board)
    super
    @name = "Player #{number}"
    @input_attempt = 0
  end

  def get_move
    puts board
    puts "\n"
    input = nil
    
    loop do
      print prompt
      input = get_input_from_user
      break if valid?(input)
    end

    puts
    reset!
    Move.new(board, input, mark)
  end

  private
  def get_input_from_user
    @input_attempt += 1
    input = STDIN.gets
    if input.nil?
      puts; exit
    end
    input.chomp!
    parse_user_input(input)
  end

  def parse_user_input(string)
    return nil if string.length != 2
    /(?<number>\d)/     =~ string
    /(?<letter>[a-z])/i =~ string
    return nil if number.nil? || letter.nil?
    letter.upcase!
    [number.to_i - 1, letter.ord - 65]
  end

  def prompt
    @input_attempt == 0  \
      ? "#{name}, enter a move (ex: #{example}): "
      : "Invalid input; please try again: "
  end

  def example
    i, j = get_vital_cell || get_random_empty_cell
    i = i + 1
    j = (j + 65).chr
    j.downcase! if rand > 0.5
    rand > 0.5 ? "#{i}#{j}" : "#{j}#{i}"
  end

  def reset!
    @input_attempt = 0
  end
end

class ComputerPlayer < Player
  attr_reader   :difficulty
  attr_accessor :print_board
  
  def initialize(number, mark, board)
    super
    @difficulty = :medium
    @print_board = false
    if number
      @name = "Computer #{number}"
    else
      @name = "Computer"
    end
  end

  def get_move
    if print_board
      puts board
      puts "\n"
    end
    move = get_move_from_difficulty
    fail "AI is broken" unless valid?(move)
    Move.new(board, move, mark)
  end

  def difficulty=(sym)
    fail "invalid difficulty" unless [:easy, :medium, :hard].include?(sym)
    @difficulty = sym
  end

  private
  def get_move_from_difficulty
    send difficulty_hash[difficulty]
  end

  def difficulty_hash
    @dh ||= { :easy   => :easy_move,
              :medium => :medium_move,
              :hard   => :hard_move }
  end

  def easy_move
    get_random_empty_cell
  end

  def medium_move
    get_vital_cell(mark) || get_random_empty_cell
  end

  def hard_move
    get_vital_cell(mark) || get_best_move
  end

  def get_best_move

  end
end

if $PROGRAM_NAME == __FILE__
  Game.run
end
