class Hyperion
	module Finders

		# find(id)
		# find(:all, {})
		# find(:first, {})
		# find(:last, {})
		
		# we can do > and < if we use ZRANGEBYSCORE
		
		# DEPRECATED
		def first(conds)
			# FIXME: gotta be a faster way ;)
			self.find(conds).first
		end
		
		def find2(*opts)
			if opts.length > 1 then # We're doing something magical.
				
			else
				Hyperion.logger.debug("[RS] Fetching #{self.to_s.downcase + '_' + opts.first.to_s}") if Hyperion::DEBUG
	      v = redis[self.to_s.downcase + '_' + opts.first.to_s].to_s
	      if v and not v.empty? then
	        self.deserialize(v)
	      else
	        nil
	      end
			end
		end
		
	  def find(conds)
	    Hyperion.logger.debug("[RS] Searching for #{conds.inspect}") if Hyperion::DEBUG

	    if conds.is_a? Hash then
	      Hyperion.logger.debug("[RS] Its a Hash, digging through indexes!") if Hyperion::DEBUG
	      ids = []
	      index_keys = []
	      index_values = []

	      if conds.keys.size > 1 then
	        conds.sort.each {|k,v|
	          index_values << v
	          index_keys << k.to_s
	        }
	        index_key = self.to_s.downcase + '_' + index_keys.join('.') + '_' + index_values.join('.')
	        ids << Hyperion.redis.smembers(index_key)
	      else
	        conds.each{|k,v|
	          index_key = self.to_s.downcase + '_' + k.to_s + '_' + v.to_s
	          ids << Hyperion.redis.smembers(index_key)
	        }
	      end
	      ids.flatten.uniq.collect{|i|
	        self.find(i)
	      }
	    else
	      Hyperion.logger.debug("[RS] Fetching #{self.to_s.downcase + '_' + conds.to_s}") if Hyperion::DEBUG
	      v = redis[self.to_s.downcase + '_' + conds.to_s].to_s
	      if v and not v.empty? then
	        self.deserialize(v)
	      else
	        nil
	      end
	    end
	  end
		
		
	end
end