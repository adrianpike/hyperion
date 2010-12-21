require 'active_support'
require 'yaml'
require 'redis'

# TODO: rescue this
require 'active_model'

# TODO: splat this
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
end