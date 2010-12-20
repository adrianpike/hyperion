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

   it 'should be able to find all items exact matching an index'
   # DefaultKey.find2(:all, :conditions => {:key => "test"})
   
   it 'should be able to find all items range matching an index' do
   
     10.times {|i|
      f = IndexedObject.new
      f.other_content = (100+i).to_s
      f.save
     }
     
       results = DefaultKey.find(:all, :conditions => {'other_content' => {:min => 100, :max => 200}})
       p results
     end
#  DefaultKey.find2(:first, :conditions => {:key => {:min => 'a', :max => 'z'}}, :limit => 10, :order => content)

  it 'should be able to find all items exact matching multiple indexes'
  # DefaultKey.find2(:first, :conditions => {:key => 'test', :content => string1})

  it 'should be able to find all items range matching multiple indexes'
  
end