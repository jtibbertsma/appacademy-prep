require 'w1d3/hash'

describe MyHashSet do

  before(:each) do
    @set1 = MyHashSet.new([1,2,3,4,5])
    @set2 = MyHashSet.new([4,5,6,7,8])
    @set3 = MyHashSet.new([7,8,9,10,11])
    @set4 = MyHashSet.new([2,3,4])
  end

  [:-, :difference, :|, :union, :&, :intersect,
   :delete, :insert, :<<, :include?, :+, :length, :empty?,
   :subset?, :<=, :proper_subset?, :<, :superset?, :>=,
   :proper_superset?, :>, :symmetric_difference, :^, :==, :disjoint?,
   :each, :to_a, :inspect, :keep_if
  ].each do |sym|
    it "responds to \##{sym}" do
      expect(@set1.respond_to?(sym)).to be true
    end
  end

  it 'is unordered' do
    expect(@set1).to eq(MyHashSet.new([5,4,3,2,1]))
  end

  it 'includes Enumerable' do
    Enumerable.instance_methods(false).each do |method|
      expect(@set1.respond_to?(method)).to be true
    end
  end

  describe '#difference' do
    it 'removes elements present in another set' do
      expect(@set1.difference(@set2)).to eq(MyHashSet.new([1,2,3]))
      expect(@set1 - @set2).to eq(MyHashSet.new([1,2,3]))
    end
  end

  describe '#union' do
    it 'returns a set with all elements that are in one of the sets' do
      expect(@set1.union(@set2)).to eq(MyHashSet.new([1,2,3,4,5,6,7,8]))
      expect(@set1 | @set2).to eq(MyHashSet.new([1,2,3,4,5,6,7,8]))
      expect(@set1 + @set2 + @set3).to eq(MyHashSet.new([1,2,3,4,5,6,7,8,9,10,11]))
    end
  end

  describe '#intersect' do
    it 'returns a set with the elements that are in both sets' do
      expect(@set1.intersect(@set2)).to eq(MyHashSet.new([4,5]))
      expect(@set1 & @set2 & @set3).to eq(MyHashSet.new)
    end
  end

  describe '#symmetric_difference' do
    it 'returns a set containing all elements that aren\'t in both sets' do
      expect(@set1.symmetric_difference(@set2)).to eq(MyHashSet.new([1,2,3,6,7,8]))
      expect(@set1 ^ @set2).to eq(MyHashSet.new([1,2,3,6,7,8]))
    end
  end

  describe '#delete' do
    it 'removes an element' do
      @set1.delete(3)
      expect(@set1).to eq(MyHashSet.new([1,2,4,5]))
    end

    it 'returns true if the requested item was in the set' do
      expect(@set1.delete(3)).to be true
    end

    it 'returns false if the requested item is not in the set' do
      expect(@set1.delete(:not_exist)).to be false
    end
  end

  describe '#insert' do
    it 'adds an element to the set' do
      len = @set1.length
      @set1.insert(:new_thing)
      expect(@set1).to eq(MyHashSet.new([1,2,3,4,5,:new_thing]))
      expect(@set1.length).to eq(len + 1)
    end

    it 'returns self so that multiple items can be added' do
      @set1 << :q << :w << :e << :r
      expect(@set1).to eq(MyHashSet.new([1,2,3,4,5,:q,:w,:e,:r]))
    end
  end

  describe '#include?' do
    it 'returns true if a given item is in the set' do
      expect(@set1.include?(1)).to be true
    end

    it 'returns false if a given item is not in the set' do
      expect(@set1.include?(:blah)).to be false
    end
  end

  describe '#length' do
    it 'works' do
      expect(@set1.length).to eq(5)
    end
  end

  describe '#empty' do
    it 'returns true for a new set' do
      expect(MyHashSet.new.empty?).to be true
    end

    it 'returns true after the last item has been deleted' do
      @set1.delete(5)
      @set1.delete(4)
      @set1.delete(3)
      @set1.delete(2)
      @set1.delete(1)
      expect(@set1.empty?).to be true
    end

    it 'returns false if a set has elements in it' do
      expect(@set1.empty?).to be false
    end
  end

  describe '#subset?' do
    it 'returns true if every item in this set is in another set' do
      expect(@set4.subset?(@set1)).to be true
      expect(@set4 <= @set1).to be true
    end

    it 'returns true if the sets are equal' do
      expect(@set1.subset?(@set1)).to be true
      expect(@set1 <= @set1).to be true
    end
  end

  describe '#proper_subset?' do
    it 'returns true if every item in this set is in another set' do
      expect(@set4.proper_subset?(@set1)).to be true
      expect(@set4 < @set1).to be true
    end

    it 'returns false if the sets are equal' do
      expect(@set1.proper_subset?(@set1)).to be false
      expect(@set1 < @set1).to be false
    end
  end

  describe '#superset?' do
    it 'returns true if the other set is contained within this set' do
      expect(@set1.superset?(@set4)).to be true
      expect(@set1 >= @set4).to be true
    end

    it 'returns true if the sets are equal' do
      expect(@set1.superset?(@set1)).to be true
      expect(@set1 >= @set1).to be true
    end
  end

  describe '#proper_superset?' do
    it 'returns true if the other set is contained within this set' do
      expect(@set1.proper_superset?(@set4)).to be true
      expect(@set1 > @set4).to be true
    end

    it 'returns false if the sets are equal' do
      expect(@set1.proper_superset?(@set1)).to be false
      expect(@set1 > @set1).to be false
    end
  end

  describe '#disjoint?' do
    it 'returns true if the sets have no intersection' do
      expect(@set1.disjoint?(@set3)).to be true
    end

    it 'returns false if the sets have an intersection' do
      expect(@set1.disjoint?(@set2)).to be false
    end
  end

  describe '#to_a' do
    it 'returns an equivalent array' do
      expect(@set1.to_a.sort).to eq([1,2,3,4,5])
    end

    it 'returns a sorted array' do
      expect(@set1.to_a).to eq([1,2,3,4,5])
    end
  end

  describe '#each' do
    it 'executes a block for each element in the set' do
      sum = 0
      @set1.each do |n|
        sum += n
      end
      expect(sum).to eq(15)
    end

    it 'returns an Enumerator if no block is given' do
      expect(@set1.each).to be_instance_of Enumerator
    end
  end

  describe '#keep_if' do
    it 'deletes items for which the block is false' do
      @set1.keep_if do |n|
        n % 2 == 1
      end
      expect(@set1).to eq(MyHashSet.new([1,3,5]))
    end
  end
end