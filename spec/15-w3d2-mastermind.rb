require 'w3d2/mastermind'

describe Code do
  attr_reader :code, :other, :same, :another

  before(:all) do
    @same    = Code.parse("YYYY")
    @code    = Code.parse("GBPO")
    @other   = Code.parse("GBOP")
    @another = Code.parse("RGBY")
  end

  describe "::parse" do
    it 'correctly parses user input' do
      expect(Code.parse("RBGY").colors).to eq(Code.new(%w{R B G Y}).colors)
    end
  end

  describe "#exact_matches" do
    it 'reports zero if no positions are the same' do
      expect(code.exact_matches(same)).to eq(0)
      expect(another.exact_matches(other)).to eq(0)
    end

    it 'gives the number of exact matches' do
      expect(same.exact_matches(another)).to eq(1)
      expect(code.exact_matches(other)).to eq(2)
    end
  end

  describe "#near_matches" do
    it 'reports zero if the only matching colors are in the correct positions' do
      expect(same.near_matches(another)).to eq(0)
    end

    it 'reports the number of correct colors in incorrect positions' do
      expect(code.near_matches(other)).to eq(2)
      expect(code.near_matches(another)).to eq(2)
      expect(another.near_matches(same)).to eq(3)
    end
  end
end