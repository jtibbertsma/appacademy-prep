
def multiply_by_2(array)
  array.map { |e| e * 2 }
end

class Array
  def my_each
    length.times { |n| yield at(n) } if block_given?
    self
  end
end

def median(array)
  array = array.sort
  len = array.length
  if len.even? && len > 0
    sum = array[(len/2)-1] + array[len/2]
    sum / 2.0
  else
    array[len/2]
  end
end

def concatenate(strings)
  strings.inject(:+)
end
