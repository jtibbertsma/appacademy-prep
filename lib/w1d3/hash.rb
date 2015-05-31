class MyHashSet
  include Enumerable

  def initialize(enum = [])
    @store = Hash.new { |hash, key| hash[key] = true }
    enum.each do |item|
      insert item
    end
  end

  def each(&block)
    @store.keys.each(&block)
  end

  def clone
    MyHashSet.new(to_a)
  end

  def length
    @store.length
  end

  alias :size :length

  def insert(item)
    @store[item]
    self
  end

  alias :<< :insert

  def delete(item)
    if include? item
      @store.delete(item)
      true
    else
      false
    end
  end

  def include?(item)
    @store.include? item
  end

  def union(other)
    MyHashSet.new(to_a + other.to_a)
  end

  alias :+ :union
  alias :| :union

  def difference(other)
    new_set = MyHashSet.new
    each { |item| new_set << item unless other.include?(item) }
    new_set
  end

  alias :- :difference

  def intersect(other)
    new_set = MyHashSet.new
    each { |item| new_set << item if other.include?(item) }
    new_set
  end

  alias :& :intersect

  def symmetric_difference(other)
    (self | other) - (self & other)
  end

  alias :^ :symmetric_difference

  def ==(other)
    to_a == other.to_a
  end

  def to_a
    array = @store.keys
    begin
      array.sort!
    rescue ArgumentError; end
    array
  end

  def empty?
    @store.empty?
  end

  def disjoint?(other)
    each { |item| return false if other.include?(item) }
    true
  end

  def subset?(other)
    return false if length > other.length
    MyHashSet.internal_subset(self, other)
  end

  def proper_subset?(other)
    return false if length >= other.length
    MyHashSet.internal_subset(self, other)
  end

  def superset?(other)
    return false if length < other.length
    MyHashSet.internal_subset(other, self)
  end

  def proper_superset?(other)
    return false if length <= other.length
    MyHashSet.internal_subset(other, self)
  end

  alias :<= :subset?
  alias :<  :proper_subset?
  alias :>= :superset?
  alias :>  :proper_superset?

  def self.internal_subset(set1, set2)
    set1.each { |item| return false unless set2.include?(item) }
    true
  end

  def keep_if
    each { |item| delete item unless yield(item) } if block_given?
    self
  end

end