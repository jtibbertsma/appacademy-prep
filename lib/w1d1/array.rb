
# Given an array of stocks and two indices, calculate the profit earned
# (or amount lost) by buying at the first index and selling at the second
# index. The first index should always be less than the second.
def profit(stocks, buy, sell)
  fail "sell <= buy" if sell <= buy
  stocks[sell] - stocks[buy]
end

def stock_picker(stocks)
  indices = Array.new(stocks.length) { |i| i }
  indices.combination(2).max do |a, b|
    profit(stocks, *a) <=> profit(stocks, *b)
  end
end


class Array
  # inefficient, O(n^2) in worst case
  def my_uniq
    new_array = []
    each do |item|
      new_array << item if !new_array.include?(item)
    end
    new_array
  end

  def two_sum
    each_index.to_a.combination(2).select do |i, j|
      at(i) + at(j) == 0
    end
  end
end

def my_transpose(matrix)
  len = matrix.length
  Array.new(len) do |i|
    Array.new(len) { |j| matrix[j][i] }
  end
end
