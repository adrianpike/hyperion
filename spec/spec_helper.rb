require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'hyperion'

RSpec.configure do |config|
  config.mock_with :rspec
end

class DefaultKey < Hyperion
	attr_accessor :content, :key
	hyperion_key :key
end

class NoKey < Hyperion
	attr_accessor :content
end

class IndexedObject < Hyperion
	attr_accessor :content, :other_content, :key
	
	hyperion_key :key
	hyperion_index :other_content
	hyperion_index [:content, :other_content]
end

def random_string(length = 10)
	'asdfdsfasd' # todo lolololol
end