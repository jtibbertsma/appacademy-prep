# Assumes base is between 2 and 16
def num_to_s(num, base)
  ciphers = %w(0 1 2 3 4 5 6 7 8 9 A B C D E F)
  rep = 1

  Math.log(num, base).to_i.times.map { rep *= base }
  .unshift(1)
  .inject('') { |string, div| string << ciphers[(num / div) % base] }
  .reverse
end

# Assumes lowercase ascii letters
def caesar_cipher(word, shift)
  ascii_shift = 97
  word.each_codepoint.map do |num|
    num = num - ascii_shift + shift
    num = (num % 26) + ascii_shift
  end
  .inject('', :<<)
end