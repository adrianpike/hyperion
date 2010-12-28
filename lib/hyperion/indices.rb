class Hyperion
	module Indices
		
		class NoIndex < HyperionException #:nodoc:
		end
	  class UnindexableValue < HyperionException #:nodoc:
	  end
	  
	  # This is so if values get changed, we know the original values so we can go into the indexes and sweep up.
	  def remember_initial_values #:nodoc:
	    Hyperion.logger.debug("[Hyperion] Remembering initial values on #{self.to_s}!")
	    if self.class.class_variable_defined?('@@redis_indexes') then
  	    @initial_values = {}
  	    self.class.class_variable_get('@@redis_indexes').flatten.uniq.each{|idx|
          @initial_values[idx] = self.send(idx)
        }
      end
    end
	  
	  def index_values_changed?(idx) #:nodoc:
	    return false unless @initial_values
	    if idx.is_a?(Array) then
	      idx.each {|i|
	        (return true) if (@initial_values[i] != self.send(i))
	      }
      else
        (return true) if (@initial_values[idx] != self.send(idx))
      end
      
      false
    end
	  
	  # Force a reindex. opts can include :unstore, in which case it will just remove indices, and not add new ones.
		def reindex!(opts = {})
		  # Now lets update any indexes
	    self.class.class_variable_get('@@redis_indexes').each{|idx|
	      Hyperion.logger.debug("[Hyperion] Updating index for #{idx}")
  		  
	      if index_values_changed?(idx) or opts[:unstore] then
	        Hyperion.logger.debug("[Hyperion] Clearing old index for #{idx}")
	        
	        if Hyperion::V2_KEYS then
    	      if idx.is_a?(Array) then
    	        index_key = self.class.to_s.downcase + '_' + idx.sort.join('.').to_s
    	      else
    					index_key = self.class.to_s.downcase + '_' + idx.to_s
            end
            Hyperion.redis.zrem(index_key, self.send(self.class.class_variable_get('@@redis_key')))
          else
  	        if idx.is_a?(Array) then
              index_values = idx.sort.collect {|i| @initial_values[i] }.join('.')
              index_key = self.class.to_s.downcase + '_' + idx.sort.join('.').to_s + '_' + index_values
            else
              value = @initial_values[idx]
              index_key = self.class.to_s.downcase + '_' + idx.to_s + '_' + value.to_s if value
            end
            Hyperion.redis.srem(index_key, self.send(self.class.class_variable_get('@@redis_key')))
          end
          Hyperion.logger.debug("[Hyperion] Removed index #{index_key}: #{self.send(self.class.class_variable_get('@@redis_key'))}")
	      end
	      
	      unless opts[:unstore] then
	        if Hyperion::V2_KEYS then
    	      if idx.is_a?(Array) then
    	        value = idx.sort.collect {|i| self.send(i) }.join('.')
    	        index_key = self.class.to_s.downcase + '_' + idx.sort.join('.').to_s
    	      else
    					value = self.send(idx)
    	        index_key = self.class.to_s.downcase + '_' + idx.to_s
            end
            if value then
              score = Hyperion.score(value)
              Hyperion.redis.zadd(index_key, score, self.send(self.class.class_variable_get('@@redis_key')))
    	        Hyperion.logger.debug("[Hyperion] Saving index #{index_key}: #{self.send(self.class.class_variable_get('@@redis_key'))} - #{score}")
    	      end
          else # v1 indexes
    	      if idx.is_a?(Array) then
    	        value = idx.sort.collect {|i| self.send(i) }.join('.')
    	        index_key = self.class.to_s.downcase + '_' + idx.sort.join('.').to_s + '_' + value
    	      else
    					value = self.send(idx)
    	        index_key = self.class.to_s.downcase + '_' + idx.to_s + '_' + value.to_s if value
    	      end
    	      Hyperion.redis.sadd(index_key, self.send(self.class.class_variable_get('@@redis_key')))
    	      Hyperion.logger.debug("[Hyperion] Saving index #{index_key}: #{self.send(self.class.class_variable_get('@@redis_key'))}")
    	    end
    	    
  	    end
	    } if self.class.class_variable_defined?('@@redis_indexes')
		end
		
		def self.included(where) #:nodoc:
		   where.extend ClassMethods
		end
		
		module ClassMethods

      # Define an indexed attribute on a Hyperion model.
      #   class Foo < Hyperion
      #     attribute :number_of_awesomeness
      #     hyperion_index :number_of_awesomeness
      #   end
      # Now, any time a Foo is created/modified/updated, an index will be updated for the number_of_awesomeness attribute, 
      # and so you'll be able to query based upon number_of_awesomeness.
			def hyperion_index(index)
		    if class_variable_defined?(:@@redis_indexes) then
		      class_variable_set(:@@redis_indexes, class_variable_get(:@@redis_indexes) << index)
		    else
		      class_variable_set(:@@redis_indexes, [index])
		    end
		  end
		
			# TODO: Explore max ZSET score size.
		
		  # Score is pretty much magic. It converts your index values into floats, suitable for Redis' ZSETs.
		  # Now here's where it gets fun - if you give Hyperion something other than a Float,Fixnum,Bignum, or String,
		  # it's awful tough for Hyperion to know how to crush that into a suitable ZSET value, so all you do is specify a
		  # zset_score method on that object, and Hyperion will use that.
			def score(value)
				case value
				when Float,Fixnum,Bignum
					value
				when String
					string_value(value)
				when nil
				  nil
				else
					if value.respond_to? :zset_score then
						score value.zset_score # TODO: limit recursion
					else
						raise UnindexableValue
					end
				end
			end
		
			private
				# Give me a float-representation of a string
				def string_value(string) #:nodoc:
					vals = []
					string.upcase.each_byte{|c|
						if (c>="0".ord and c<="9".ord) then
							vals << (c - "0".ord)
						elsif (c>="A".ord and c<="Z".ord)
							vals << (c - "A".ord + 10)
						end
					}

					base=0
					vals[1..-1].inject(vals.first.to_f) {|memo, obj|
						base+=1
						val = (obj.to_f/(36 ** base))
						memo += val
					}
				end
			end
	end
end