def add(a, b)
  a + b
end

def subtract(a, b)
  a - b
end

def sum(nums)
  nums.inject(0, :+)
end

def multiply(*nums)
  nums.inject(1, :*)
end

def power(a, b)
  a ** b
end

def factorial(num)
  fail "Saw num less than 0" if num < 0
  if num == 0
    1
  else
    multiply(*(1..num).to_a)
  end
end