
# Run Program
class Program
  def self.invoke
    run_stdin or run_files
  end

  def self.run_files
    ARGV.each do |filename|
      safe do
        File.open(filename) do |f|
          print filename + ': ' if ARGV.size > 1
          run_file f
        end
      end
    end
  end

  def self.run_stdin
    return nil unless ARGV.empty?
    run_from_keyboard or safe { run_file($stdin) }
  end

  def self.run_from_keyboard
    return nil unless $stdin.tty?

    prompt = '--> '
    calculator = RPNCalculator.new

    loop do
      print prompt
      input = gets or break :out_of_loop
      safe { puts calculator.evaluate(input) }
      puts
    end
  end

  def self.safe
    begin
      yield
    rescue IOError, RuntimeError => e
      puts e
    end
  end

  def self.run_file(file)
    puts RPNCalculator.new.evaluate(file.read)
  end
end


# Calculator class
class RPNCalculator
  def self.supported_operations
    {
      :plus => :+, :minus => :-, :times => :*,
      :divide => :/, :modulo => :%, :and => :&,
      :or => :|, :exp => :**
    }
  end

  # instance methods
  def initialize
    @stack = RPNStack.new
  end

  def push(num)
    @stack.push num
    self
  end

  def value
    @stack.top
  end

  supported_operations.each do |name, symbol|
    define_method(name) { operation symbol }
  end

  def tokens(string)
    Tokenizer.new(string).tokens
  end

  def evaluate(string)
    tokens(string).each do |tok|
      if tok.is_a? Numeric
        push tok
      else
        operation tok
      end
    end
    value
  end

  private
  def operation(op)
    values = @stack.pop
    push values.operation_result(op)
  end
end


class RPNStack
  def initialize
    @internal = []
  end

  def top
    @internal[-1]
  end

  def push(item)
    @internal.push item.to_f
  end

  def pop
    ValuePair.new(@internal.pop, @internal.pop)
  end
end


class ValuePair
  def initialize(*values)
    raise "calculator is empty" if values.any? { |num| num.nil? }
    @right, @left = *values
  end

  def operation_result(op)
    @left.send(op, @right)
  end
end


class Tokenizer
  def initialize(string)
    @data = string.split
  end

  def tokens
    @data.map { |item| classify item }
  end

  private
  def classify(string)
    get_number(string) or get_symbol(string) or raise "bad input: #{string}"
  end

  def get_number(string)
    return nil unless /[+-]?\d+(?<float>\.\d+)?/ =~ string
    return string.to_f if float
    string.to_i
  end

  def get_symbol(string)
    return nil unless /#{symbol_regex}/ =~ string
    string.to_sym
  end

  def symbol_regex
    RPNCalculator.supported_operations.values.map { |sym| '\\' + sym.to_s }
    .join('|')
  end
end


if __FILE__ == $PROGRAM_NAME
  Program.invoke
end