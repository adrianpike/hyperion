require 'spec_helper'
# TODO: truncate the redis store and/or stub it beforehand

class FiredCallback < Exception; end

class CallbackedObject < Hyperion

  attr_accessor :content, :key
  hyperion_key :key
  
  before_save :do_stuff
    
  def do_stuff
    raise FiredCallback
  end
  
  
end

describe 'Hyperion callbacks' do

  it 'should fire before_save' do
    
    obj = CallbackedObject.new
    obj.content = 'foodebar'
    lambda { obj.save }.should raise_error(FiredCallback)
    
  end

end