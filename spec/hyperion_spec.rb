require 'spec_helper'
# TODO: truncate the redis store and/or stub it beforehand

describe 'Hyperion' do
  it "should work for basic set/fetch" do
		string1 = random_string
	
    f = DefaultKey.new
		f.key = 'test'
		f.content = string1
		f.save
		
		f2 = DefaultKey.find('test')
		f2.content.should == f.content
		
		f3 = IndexedObject.find(string1)
		f3.should == nil
  end

	it "should be able to index a single attribute" do
		string1 = random_string
		
		f = IndexedObject.new
		f.content = string1
		f.other_content = 'zero_cool'
		f.key = 'testery'
		f.save
		
		f2 = IndexedObject.first(:other_content => 'zero_cool')
		f2.content.should == f.content
		
		f3 = IndexedObject.find('testery')
		f3.content.should == f.content
	end
	
	it "should take objects at instantiation time" do
		string1 = random_string
		
		n=NoKey.new(:content => string1)
		n.save
		
		n2 = NoKey.find(n.id)
		n2.content.should == string1
	end
	
	it "should autogenerate keys" do
		string1 = random_string
		
		n=NoKey.new
		n.content = string1
		n.save
		
		n2 = NoKey.find(n.id)
		n2.content.should == string1
	end
	
	it 'should autoincrement keys whether specified or not' do
	end
	
	it "should be able to index multiple attributes" do
		string1 = random_string
		
		f = IndexedObject.new
		f.content = string1
		f.other_content = 'zero_cool'
		f.key = 'testery'
		f.save
		
		f2 = IndexedObject.first(:other_content => 'zero_cool')
		f2.content.should == f.content
		
		f3 = IndexedObject.find('testery')
		f3.content.should == f.content
		
		f4 = IndexedObject.first(:other_content => 'zero_cool', :content => string1)
		f4.content.should == f.content
	end
	
	it "shouldn't put an index in for an empty value" do
		string1 = random_string
		
		f = IndexedObject.new
		f.content = string1
		f.save
		
		f2 = IndexedObject.first(:other_content => nil)
		f2.should == nil
	end
	
	it "shouldn't matter what order your indexes are specified" do
	end
	
	it "should not have concurrency issues" do
	end

	it "should reindex objects when I update them" do
	  
	  
	  
	end

	it "should delete objects and their indexes when i delete them" do
	end
	
	it 'should be OK with key collision' do
	end
		
	it "should die if there's no redis server around" do
	end
	
	it "should allow crazy lengths and contents for both keys and values" do
	end

end