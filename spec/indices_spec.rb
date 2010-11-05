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
    class IndexableObject < Array
      def zset_score
        self.count
      end
    end
    
    a = IndexableObject.new
    a << 'foo'; a << 'bar'
    b = IndexableObject.new
    b << 'foo'; b << 'bar'; b << 'baz'
    expect {
      Hyperion.score(a).should < Hyperion.score(b)
    }.should_not raise_error(Hyperion::Indices::UnindexableValue)
  end
end