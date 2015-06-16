module GameClassMethods
  Version = "0.0.1"
  def option_specification(options)
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby tic-tac-toe.rb [options]"

      opts.separator ""
      opts.separator "Game Modes:"

      seen_mode = false
      mode_check = Proc.new do |new_mode|
        if seen_mode && new_mode != options[:game_type]
          raise OptionParser::AmbiguousArgument.new(
            "#{new_mode}, #{options[:game_type]}"
          )
        end
        seen_mode = true
      end

      opts.on("-a", "--computer-computer", "Computer vs Computer") do
        mode_check.call(:computer_vs_computer)
        options[:game_type] = :computer_vs_computer
      end

      opts.on("-b", "--human-human", "Human vs Human") do
        mode_check.call(:human_vs_human)
        options[:game_type] = :human_vs_human
      end

      opts.on("-c", "--human-computer", "Human vs Computer (default)") do
        mode_check.call(:human_vs_computer)
        options[:game_type] = :human_vs_computer
      end

      opts.separator ""
      opts.separator "Difficulty Levels:"

      opts.on("-e", "--easy", "Computer will move randomly") do
        options[:difficulty] << :easy
      end

      opts.on("-m", "--medium", "Computer will win if possible and will",
        "  block wins") do
        options[:difficulty] << :medium
      end

      opts.on("-h", "--hard", "Computer will use the optimal strategy") do
        options[:difficulty] << :hard
      end

      opts.on("-d", "--difficulty easy|medium|hard",
        "Set difficulty level",
        "  (can be included twice for computer vs",
        "  computer mode)") do |diff|
        diff = diff.to_sym
        unless [:easy, :medium, :hard].include?(diff)
          raise OptionParser::InvalidArgument.new(
            "Invalid difficulty level: #{diff}"
          )
        end
        options[:difficulty] << diff
      end

      opts.separator ""
      opts.separator "Display Options:"

      opts.on("-t", "--stretch-factor NUM", OptionParser::DecimalInteger,
        "Width of tic-tac-toe board column",
        "  (9 by default; must be odd)") do |num|
        if num % 2 == 0
          raise OptionParser::InvalidArgument.new(
            "Stretch factor must be odd; got #{num}"
          )
        end
        options[:stretch_factor] = num
      end

      opts.on("-p", "--padding NUM", OptionParser::DecimalInteger,
        "Number of spaces in from of printed board",
        "  (0 by default)") do |num|
        options[:padding] = num
      end

      opts.on("-z", "--print-board", "Print board before computer's turn") do
        options[:print_board] = true
      end

      opts.separator ""
      opts.separator "Player Names:"

      opts.on("-n", "--name STRING",
        "Specify a player name.") do |name|
        options[:names] << name
      end

      opts.on("-y", "--humans-only",
        "Names given with -n won't affect", "  computer players") do
        options[:humans_only] = true
      end

      opts.separator ""
      opts.separator "  Multiple names can be specified to affect multiple "\
                     "players."
      opts.separator "  Human players are affected before computer players. "\
                     "In human vs"
      opts.separator "  human mode and computer vs computer mode, the "\
                     "starting player"
      opts.separator "  is affected first."
      opts.separator ""

      opts.separator ""
      opts.separator "Configuration:"

      opts.on("-f", "--file FILENAME",
        "Specify configuration file path.") do |filename|
        unless File.exist?(filename)
          raise OptionParser::InvalidArgument.new(
            "'#{filename}' doesn't exist"
          )
        end
        options[:config_file] = filename
      end

      opts.separator ""
      opts.separator "  If this option is not included, the folder "\
                     "containing this file"
      opts.separator "  will be checked for a file called .tic-tac-toe, "\
                     "which will"
      opts.separator "  be used as the config file if it exists. Any "\
                     "options given in"
      opts.separator "  a config file will be overwritten by options "\
                     "given on the command"
      opts.separator "  line. If -f is given in a config file, "\
                     "it will be ignored."

      opts.separator ""
      opts.separator "Other Options:"

      opts.on("--help", "Show this message") do
        puts opts
        exit
      end

      opts.on("--version", "Print version and exit") do
        puts Version
        exit
      end

      opts.on("-s", "--size SIZE", "Use a SIZExSIZE board",
        OptionParser::DecimalInteger,
        "  (must be between 3 and 9 inclusive)") do |size|
        if size < 3 || size > 9
          raise OptionParser::InvalidArgument.new(
            "size must be between 3 and 9 inclusive"
          )
        end
        options[:board_size] = size
      end

      opts.on("-g", "--go-second", "Go second",
        "  Allows the human player to go second in",
        "  human vs computer mode.") do
        options[:go_second] = true
      end

      opts.on("-o", "--o-goes-first",
        "Allow the starting player to use O",
        "  instead of X") do
        options[:o_goes_first] = true
      end
    end
  end
end