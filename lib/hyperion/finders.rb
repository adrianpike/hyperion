class Hyperion
	module Finders
    # == Hyperion Finders
    #
    # The finder methods look strikingly similar to ActiveRecord's. This isn't really a coincidence. :)

    
    # If you're just wanting to fetch an object by its key, include just the key as the only argument.
    #
    # If you'd like to fetch a collection of results, or using a more complicated set of conditions, the first argument should be one of 
    # :all, :first, or :last.
    # 
    # == Parameters
    # - :conditions - Either an Array, in which case it will fetch results that match any of the items,
    # a Hash with a :min and a :max key, in which case it will fetch results between two items (inclusive),
    # or a String, in which case it will fetch all items that match the string.
    # - :order - not built yet!
    # - :limit - also, not built yet.
    #
    # == Examples
		#   find(5)
		#   find(:all, :conditions => {:indexed_item => ['1','2','3']})
		#   find(:first, :conditions => {:indexed_item => '31337'})
		#   find(:last, :conditions => {:indexed_item => {:min => 12, :max => 50}})
		def find(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      
      if args.first.is_a?(Symbol) then # We're doing something magical.
        conds = options[:conditions]
        object_ids = []
        
        conds.each {|key,conditions|
          if (key==self.class_variable_get('@@redis_key')) then
            object_ids << [conditions.to_s]
          else
            # TODO: raise an exception if this key isn't indexed
            case conditions
            when Hash
              # raise an exception if we don't have min & max
              object_ids << redis.zrangebyscore(self.to_s.downcase+'_'+key.to_s, Hyperion.score(conditions[:min]), Hyperion.score(conditions[:max]))
            when Array
              # OR this junk together to build our query
              # TODO: Actually do this.
            else
              object_ids << redis.zrangebyscore(self.to_s.downcase+'_'+key.to_s, Hyperion.score(conditions), Hyperion.score(conditions))
              # just do a straight query
            end
          end
        }
        
        results = object_ids.flatten.uniq.collect {|id|
          self.find(id)
        }

        # TODO: Limits
        
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
		
		def legacy_find(conds) #:nodoc:
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