class Hyperion
	module Finders

		# find(id)
		# find(:all, {})
		# find(:first, {})
		# find(:last, {})
		
		# we can do > and < if we use ZRANGEBYSCORE
		
		def find(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      
      if args.first.is_a?(Symbol) then # We're doing something magical.
        conds = options[:conditions]
        object_ids = []
        
        conds.each {|key,conditions|
          # TODO: raise an exception if this key isn't indexed

          case conditions
          when Hash
            # raise an exception if we don't have min & max
            object_ids << redis.zrangebyscore(self.to_s.downcase+'_'+key.to_s, conditions[:min], conditions[:max])
          when Array
            # OR this junk together to build our query
          else
            object_ids << redis.zrangebyscore(self.to_s.downcase+'_'+key.to_s, Hyperion.score(conditions), Hyperion.score(conditions))
            # just do a straight query
          end
        }
        
        results = object_ids.flatten.uniq.collect {|id|
          self.find(id)
        }

        # PERFORMANCE: only fetch what's needed
        case args.first
          when :last
            results.last
          when :first
            results.first
          else
            results
        end
			else
				Hyperion.logger.debug("[Hyperion] Fetching #{self.to_s.downcase + '_' + args.first.to_s}")
	      v = redis[self.to_s.downcase + '_' + args.first.to_s].to_s
	      if v and not v.empty? then
	        self.deserialize(v)
	      else
	        nil
	      end
			end
		end
		
		# DEPRECATED FINDER
	  def legacy_find(conds)
	    Hyperion.logger.debug("[Hyperion] Searching for #{conds.inspect}")

	    if conds.is_a? Hash then
	      Hyperion.logger.debug("[Hyperion] Its a Hash, digging through indexes!") if Hyperion::DEBUG
	      ids = []
	      index_keys = []
	      index_values = []

	      if conds.keys.size > 1 then
	        conds.sort.each {|k,v|
	          index_values << v
	          index_keys << k.to_s
	        }
	        index_key = self.to_s.downcase + '_' + index_keys.join('.') + '_' + index_values.join('.')
	        ids << Hyperion.redis.zrange(index_key,0,0)
	      else
	        conds.each{|k,v|
	          index_key = self.to_s.downcase + '_' + k.to_s + '_' + v.to_s
	          ids << Hyperion.redis.zrange(index_key,0,0)
	        }
	      end
	      ids.flatten.uniq.collect{|i|
	        self.find(i)
	      }
	    else
	      Hyperion.logger.debug("[Hyperion] Fetching #{self.to_s.downcase + '_' + conds.to_s}") if Hyperion::DEBUG
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