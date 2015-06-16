require 'w2d3/classes'

describe Student do
  attr_accessor :student

  before(:each) do
    @student = Student.new('Joseph', 'Tibbertsma')
  end

  describe '#name' do
    it 'gives the full name of the student' do
      expect(student.name).to eq("Tibbertsma, Joseph")
    end
  end

end