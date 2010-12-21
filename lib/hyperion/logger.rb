require 'logger'

class Hyperion
	module Logger #:nodoc:
		
		def logger #:nodoc:
			unless class_variable_defined?('@@logger') then
				@@logger = ::Logger.new(STDOUT)
				@@logger.level = ::Logger::DEBUG
			end
			
			@@logger
		end
		
	end
end