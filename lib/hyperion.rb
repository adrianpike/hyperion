require 'active_support'
require 'yaml'
require 'redis'

# TODO: splat this
require 'hyperion/base'
require 'hyperion/indices'
require 'hyperion/keys'
require 'hyperion/logger'
require 'hyperion/version'
require 'hyperion/finders'

class Hyperion
	include Keys
	include Indices
	
	extend Finders
	extend Version
	extend Logger
	
  DEBUG = false
  # TODO: ActiveModel lint
  # TODO: atomic operations
end