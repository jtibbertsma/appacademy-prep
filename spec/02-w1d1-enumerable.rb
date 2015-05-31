require 'w1d1/enumerable'

describe '#multiply_by_2' do
  it 'does what it advertises' do
    expect(multiply_by_2([1, 2, 3, 4, -23])).to eq([2 ,4, 6, 8, -46])
  end
end

describe Array do
  it 'responds to #my_each' do
    expect([].respond_to?(:my_each)).to be true
  end

  describe '#my_each' do
    let(:array) { [1, 2, 3] }

    it 'doesn\'t call #each' do
      expect(array).to_not receive(:each)
      array.my_each { 1 + 1 }
    end

    it 'returns the original array' do
      expect(array.my_each).to be array
    end

    it 'executes the block the right number of times' do
      count = 0
      block = Proc.new { count += 1 }
      array.my_each(&block).my_each(&block).my_each(&block)
      expect(count).to eq(array.length * 3)
    end
  end
end

describe '#median' do
  it 'finds the median of an array' do
    expect(median([1,2,3,4,5].shuffle!)).to eq(3)
  end

  it 'averages the middle two if the array has an even length' do
    expect(median([1,2,3,4,5,6].shuffle!)).to eq(3.5)
  end
end

describe '#concatenate' do
  let(:strings) { ["Yay ", "for ", "strings!"] }

  it 'uses #inject' do
    expect(strings).to receive(:inject)
    concatenate(strings)
  end

  it 'gives the correct output' do
    expect(concatenate(strings)).to eq("Yay for strings!")
  end
end
