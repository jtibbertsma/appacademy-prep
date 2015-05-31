require 'w1d3/string'

describe '#num_to_s' do
  it 'translates into base 10' do
    #expect(num_to_s(5, 10)).to eq('5')
    expect(num_to_s(234, 10)).to eq('234')
  end

  it 'translates into binary' do
   # expect(num_to_s(5, 2)).to eq('101')
    expect(num_to_s(234, 2)).to eq('11101010')
  end

  it 'translates into hex' do
    #expect(num_to_s(5, 16)).to eq('5')
    expect(num_to_s(234, 16)).to eq('EA')
  end
end

describe '#caesar_cipher' do
  it 'shifts a word by 3 characters' do
    expect(caesar_cipher('hello', 3)).to eq('khoor')
  end

  it 'wraps around to the beginning of the alphabet' do
    expect(caesar_cipher('zany', 2)).to eq('bcpa')
  end
end