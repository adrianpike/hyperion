require 'spec_helper'

describe 'Hyperions finders' do
	it 'should be able to find a single item by key' do
		string1 = random_string
		f = DefaultKey.new
		f.key = 'test'
		f.content = string1
		f.save
		
		f2 = DefaultKey.find2('test')
		f2.content.should == f.content
		
		f3 = DefaultKey.find2(:all, :conditions => {:key => "test"})
		f3.content.should == f.content
		
		f4 = DefaultKey.find2(:first, :conditions => {:key => 'test', :content => string1})
		f4.content.should == f.content
	
		f5 = DefaultKey.find2(:first, :conditions => {:key => {:min => 'a', :max => 'z'}}, :limit => 10, :order => content)
	end

	it 'should be able to find all items exact matching an index' do
	end

	it 'should be able to find all items range matching an index' do
	end

	it 'should be able to find all items exact matching multiple indexes' do
	end

	it 'should be able to find all items range matching multiple indexes' do
	end
	
end