require 'spec_helper'

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
    
    f2 = IndexedObject.find(:first, :conditions => {:other_content => 'zero_cool'})
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
        
        f2 = IndexedObject.find(:first, :conditions => {:other_content => 'zero_cool'})
        f2.content.should == f.content
        
        f3 = IndexedObject.find('testery')
        f3.content.should == f.content
        
        f4 = IndexedObject.find(:first, :conditions => {:other_content => 'zero_cool', :content => string1})
        f4.content.should == f.content
      end
    
    it "shouldn't put an index in for an empty value" do
      string1 = random_string
      
      f = IndexedObject.new
      f.content = string1
      f.save
      
      f2 = IndexedObject.find(:first, :conditions => {:other_content => nil})
      f2.should == nil
    end
        
        it "should reindex objects when I update them" do
          string1 = random_string
          string2 = random_string
          
          f = IndexedObject.new
          f.content = random_string
          f.other_content = string1
          f.save
          
            f2 = IndexedObject.find(:first, :conditions => {:other_content => string1})
            f2.content.should == f.content
            f2.other_content = string2
            f2.save
        
          f3 = IndexedObject.find(:first, :conditions => {:other_content => string1})
          f3.should == nil
          
          f4 = IndexedObject.find(:first, :conditions => {:other_content => string2})
          f4.content.should == f.content
        end
        
          it "should delete objects and their indexes when i delete them" do
            string1 = random_string
          f = IndexedObject.new
          f.content = random_string
          f.other_content = string1
          f.save
          
            f1 = IndexedObject.find(f.key)
            f1.content.should == f.content
          
            f2 = IndexedObject.find(:first, :conditions => {:other_content => string1})
            f2.content.should == f.content
            f2.delete
            
            f3 = IndexedObject.find(:first, :conditions => {:other_content => string1})
            f3.should == nil
        
            f4 = IndexedObject.find(f.key)
            f4.should == nil
          end
        
    it "should set up an attribute for the key if not specified"
    it "should make a key if not specified"
    it "should yell at you if you query on an unindexed attribute"
    it "should keep metadata per Object around whats indexed versus not"
    it "should be able to reindex Objects"
    it "should be safely concurrent during a reindex"
    it "shouldn't matter what order your indexes are specified"
    it "should not have concurrency issues"
    it 'should be OK with key collision'
    it "should die if there's no redis server around"
    it "should allow crazy lengths and contents for both keys and values"
    it 'should be able to use namespaces' 
    it 'should return sane results when I combine two indexes that arent specified as a compound index'
end