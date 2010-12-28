require 'active_support'
require 'yaml'
require 'redis'

require 'active_model'

Dir["hyperion/*"].each {|file| require file }

require 'hyperion/base'
require 'hyperion/indices'
require 'hyperion/keys'
require 'hyperion/logger'
require 'hyperion/version'
require 'hyperion/finders'

require 'hyperion/hyperion_active_model'

class Hyperion #:nodoc:
  # = Hyperion
  # 

  
	include Keys
	include Indices
  include HyperionActiveModel
	
	extend Finders
	extend Version
	extend Logger
	
  DEBUG = false
  V2_KEYS = true
  
 
 # FIXME 
#  ActiveSupport::Deprecation.deprecate_methods(Hyperion.class,:attr_accessor)
#  ActiveSupport::Deprecation.deprecate_methods(Hyperion,:hyperion_defaults)
#  ActiveSupport::Deprecation.deprecate_methods(Hyperion,:legacy_find)
  
end