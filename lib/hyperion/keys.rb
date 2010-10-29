class Hyperion
	module Keys
	
		def self.included(where); where.extend ClassMethods; end
		
		module ClassMethods
		  def hyperion_key(key, opts = {})
		    class_variable_set(:@@redis_key, key)
		    class_variable_set(:@@redis_generate_key, opts[:generate])
		  end
		end

		def rekey
			unless (self.class.class_variable_defined?('@@redis_key')) then
				self.class.send('attr_accessor', 'id')
		    self.class.class_variable_set('@@redis_key', 'id')
			end

			unless (self.send(self.class.class_variable_get('@@redis_key'))) then
	      Hyperion.logger.debug("[RS] Generating new key!") if Hyperion::DEBUG
	      self.send(self.class.class_variable_get('@@redis_key').to_s + '=', new_key)
	    end
		end
		
	  private
	    def new_key
	      if (self.class.class_variable_defined?('@@redis_generate_key') and self.class.class_variable_get('@@redis_generate_key') == false)
	        raise NoKey
	      else
	        Hyperion.redis.incr(self.class.to_s.downcase + '_' + self.class.class_variable_get('@@redis_key').to_s)
	      end
	    end

	    def full_key
	      self.class.to_s.downcase + '_' + self.send(self.class.class_variable_get('@@redis_key')).to_s
	    end
	
	end
end