require 'spec_helper'

describe 'Hyperions newfangled finders' do
  it 'should be able to find a single item by key' do
    string1 = random_string
    f = DefaultKey.new
    f.key = 'test'
    f.content = string1
    f.save
    
    f2 = DefaultKey.find('test')
    f2.content.should == f.content
  end 
  
  it 'should be able to find all items exact matching an index' do
   string1 = random_string
   f = DefaultKey.new
   f.key = 'shazams'
   f.content = string1
   f.save
   
   f2 = DefaultKey.find(:all, :conditions => {:key => 'shazams' })
   f2.size.should == 1
   f2.first.content.should == f.content
  end
   
      
  it 'should be able to find all items range matching an index' do
  
    10.times {|i|
      f = IndexedObject.new
      f.other_content = (100+i).to_s
      f.save
    }
    
    results = IndexedObject.find(:all, :conditions => {'other_content' => {:min => "100", :max => "200"}})
    results.size.should == 10
    
    # cleanup
    10.times {|i|
      results[i].other_content.should == (100+i).to_s
      results[i].delete
    }
    
    results = IndexedObject.find(:all, :conditions => {'other_content' => {:min => "100", :max => "200"}})
    results.size.should == 0
  end

  it 'should give me the first result'
  it 'should give me the last result'  
  # DefaultKey.find2(:first, :conditions => {:key => {:min => 'a', :max => 'z'}}, :limit => 10)
  # DefaultKey.find2(:first, :conditions => {:key => 'test', :content => string1})
  it 'should be able to find all items exact matching multiple indexes'
  it 'should be able to find all items range matching multiple indexes'
end