require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'hyperion'

require 'test/unit'


class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests  
 
  class SampleModel < Hyperion
    
    attr_accessor :content, :key
  	hyperion_key :key
    
  end
 
  def setup
    @model = SampleModel.new
  end
end

