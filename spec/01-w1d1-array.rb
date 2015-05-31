require 'w1d1/array'

describe Array do
  [:my_uniq, :two_sum].each do |message|
    it "responds to \##{message}" do
      expect([].respond_to?(message)).to be true
    end
  end

  describe '#my_uniq' do
    it 'eliminates duplicate items' do
      expect([1, 2, 1, 3, 3].my_uniq).to eq([1, 2, 3])
    end
  end

  describe '#two_sum' do
    it "finds all pairs of positions whose elements sum to zero" do
      expect([-1, 0, 2, -2, 1].two_sum).to eq([[0, 4], [2, 3]])
    end
  end
end

describe '#my_transpose' do
  it 'transposes a square matrix' do
    matrix = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8]
    ]
    transpose = [
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8]
    ]
    expect(my_transpose(matrix)).to eq(transpose)
  end
end

describe '#stock_picker' do
  it 'picks the correct pair of days' do
    days = [2,3,4,1,2,3,4,5,6]
    expect(stock_picker(days)).to eq([3,8])
  end
end
