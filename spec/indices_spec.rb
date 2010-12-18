require 'spec_helper'

describe 'Hyperions indices' do
  
  it 'should give sane scores to strings' do

    Hyperion.score('0').should < Hyperion.score('1')
    Hyperion.score('0').should < Hyperion.score('a')
    Hyperion.score('aaa').should < Hyperion.score('azb')
    Hyperion.score('A').should < Hyperion.score('z')

  end

  it 'should give sane scores to numbers' do
    Hyperion.score(0).should < Hyperion.score(1.32132)
    Hyperion.score(4).should < Hyperion.score(5)
  end

  it 'should raise errors if i try to score things that make no sense' do
    lambda { Hyperion.score(['foo','bar'])}.should raise_error(Hyperion::Indices::UnindexableValue)
  end
  
  it 'should score an object that provides a zset_score method' do
    class IndexableObjectByScore < Array
      def zset_score
        self.count
      end
    end
    
    a = IndexableObjectByScore.new
    a << 'foo'; a << 'bar'
    b = IndexableObjectByScore.new
    b << 'foo'; b << 'bar'; b << 'baz'
    expect {
      Hyperion.score(a).should < Hyperion.score(b)
    }.should_not raise_error(Hyperion::Indices::UnindexableValue)
  end
  
  it 'should score an object that provides a zset_score method' do
    class IndexableObjectByString < Array
      def zset_score
        self.join
      end
    end
        
    a = IndexableObjectByString.new
    a << 'aaa'; a << 'bbb'
    b = IndexableObjectByString.new
    b << 'aaa'; b << 'ccc'
    
    Hyperion.score(a).should be_kind_of(Numeric)
    expect {
      Hyperion.score(a).should < Hyperion.score(b)
    }.should_not raise_error(Hyperion::Indices::UnindexableValue)
  end
end