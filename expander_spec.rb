require 'rspec'
require 'expander'
describe Expander do
  subject {Class.new {include Expander}.new }

  let(:wildcard) { ['a'..'z', '0'..'9'].inject([]) {|m,v| m + v.to_a} }
  describe '.parse_and_expand' do
    it 'should create combinations of parsed strng values' do
      subject.parse_and_expand('[a|b|][1|2]').should == [
        ['a','1'],['a','2'],
        ['b','1'],['b','2']]
    end
    it 'should substitute and permute character classes' do
      subject.parse_and_expand('[a][\d]').should == [
        ['a', '0'],
        ['a', '1'],
        ['a', '2'],
        ['a', '3'],
        ['a', '4'],
        ['a', '5'],
        ['a', '6'],
        ['a', '7'],
        ['a', '8'],
        ['a', '9']
      ]
    end
  end

  describe '.parse' do
    it 'converts patterns into arrays' do
      subject.parse('[a|b|c][1|2|3]').should == [['a','b','c'], ['1','2','3']]
    end

    it 'should substitute character classes' do
      subject.parse('[a][\d]').should == [
        ['a'],['0','1','2','3','4','5','6','7','8','9'] 
      ]
    end
  end

  describe '.substitute' do
    it 'substitutes a \\w  with an array of wildcard chars' do
      subject.substitute([['\\w']]).should == [ wildcard ] 
    end

    it 'substitutes a \\d with an array of numbers' do
      subject.substitute([['\\d']]).should == [ (0..9).map {|c| c.to_s} ] 
    end

    it 'substitutes \\l with an array of letters' do
      subject.substitute([['\\l']]).should == [ ('a'..'z').to_a ] 
    end
  end
  
  describe '.parse_groups' do
    it 'should handle a single group' do
      subject.parse_groups('[a]').should == ['a']
    end

    it 'should return an array of group string' do
      subject.parse_groups('[a][b][c]').should == ['a','b','c']
    end

    it 'should return on array of group strings including | chars' do
      subject.parse_groups('[a|b][c|d]').should == ['a|b','c|d']
    end
  end

  describe ".combine" do
    it "combines two arrays" do 
      subject.combine([:a,:b], [1,2,3]).should == [ 
        [:a,1],[:a,2],[:a,3], 
        [:b,1], [:b,2], [:b,3] ]
    end

    it 'flattens permutations of sub arrays (needed for recursion)' do
      subject.combine([[:a,:b],[:c]],[1]).should == [[:a,:b,1], [:c, 1]]
    end
  end

  it '.expand combines lists of arrays' do
    subject.expand([:a,:b],[1,2],[:c,:d]).should == [[:a, 1, :c],
      [:a, 1, :d],
      [:a, 2, :c],
      [:a, 2, :d],
      [:b, 1, :c],
      [:b, 1, :d],
      [:b, 2, :c],
      [:b, 2, :d]]
  end

  context 'with longer lists' do
    let(:list) { ['a'..'c', 'A'..'C' ,1..3, 11..13] }
    it 'combines lots of arrays' do
      expect { 
        subject.expand(*list)
      }.to_not raise_error
    end
    it 'has the expected number of permutations' do
      expected_count = 1 
      list.each do |item|
        expected_count *= item.to_a.size
      end
      subject.expand(*list).size.should == expected_count
    end
  end
end
