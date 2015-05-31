def ftoc(f)
  conversion_factor = 5.0 / 9.0
  (f - 32) * conversion_factor
end

def ctof(c)
  conversion_factor = 9.0 / 5.0
  (c * conversion_factor) + 32
end