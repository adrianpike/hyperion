class Hyperion
	module Keys
	
		def self.included(where) #:nodoc:
		  where.extend ClassMethods
		end
		
		module ClassMethods
		  # Specify what attribute to use for your primary key. You really need one of these.
		  # opts can include :generate, which is a boolean value saying whether or not you want to
		  # autoincrement your key.
		  def hyperion_key(key, opts = {})
		    class_variable_set(:@@redis_key, key)
		    class_variable_set(:@@redis_generate_key, opts[:generate])
		  end
		end

    # Rekey an object, i.e. give it a new autoincremented key.
		def rekey
			unless (self.class.class_variable_defined?('@@redis_key')) then
				self.class.send('attr_accessor', 'id')
		    self.class.class_variable_set('@@redis_key', 'id')
			end

			unless (self.send(self.class.class_variable_get('@@redis_key'))) then
	      Hyperion.logger.debug("[Hyperion] Generating new key!") if Hyperion::DEBUG
	      self.send(self.class.class_variable_get('@@redis_key').to_s + '=', new_key)
	    end
		end
		
	  private
	    # Atomically get a new unique ID from the Redis store, based upon the _hyperion_key_ and the class name.
	    def new_key
	      if (self.class.class_variable_defined?('@@redis_generate_key') and self.class.class_variable_get('@@redis_generate_key') == false)
	        raise NoKey
	      else
	        Hyperion.redis.incr(self.class.to_s.downcase + '_' + self.class.class_variable_get('@@redis_key').to_s)
	      end
	    end

	    def full_key #:nodoc:
	      self.class.to_s.downcase + '_' + self.send(self.class.class_variable_get('@@redis_key')).to_s
	    end
	
	end
end