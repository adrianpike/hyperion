class Hyperion
	module Indices
		
		class NoIndex < HyperionException; end
	  class UnindexableValue < HyperionException; end
		
		def reindex!
			# Now lets update any indexes
	    # BUG: need to clear out any old indexes of us
	    self.class.class_variable_get('@@redis_indexes').each{|idx|
	      Hyperion.logger.debug("[RS] Updating index for #{idx}") if Hyperion::DEBUG

	      if idx.is_a?(Array) then
	        index_values = idx.sort.collect {|i| self.send(i) }.join('.')
	        index_key = self.class.to_s.downcase + '_' + idx.sort.join('.').to_s + '_' + index_values
	      else
					value = self.send(idx)
	        index_key = self.class.to_s.downcase + '_' + idx.to_s + '_' + value.to_s if value
	      end
	     Hyperion.logger.debug("[RS] Saving index #{index_key}: #{self.send(self.class.class_variable_get('@@redis_key'))}") if Hyperion::DEBUG
	      Hyperion.redis.sadd(index_key, self.send(self.class.class_variable_get('@@redis_key')))
	    } if self.class.class_variable_defined?('@@redis_indexes')
		end
		
		def self.included(where); where.extend ClassMethods; end
		
		module ClassMethods

			def hyperion_index(index)
		    if class_variable_defined?(:@@redis_indexes) then
		      class_variable_set(:@@redis_indexes, class_variable_get(:@@redis_indexes) << index)
		    else
		      class_variable_set(:@@redis_indexes, [index])
		    end
		  end
		
			# Indexes need to be sorted sets!
			# ZSET scores can supposedly be large floats, should explore max ZSET score size.
		
			def score(value)
				case value
					when Float,Fixnum,Bignum
						value
					when String
						string_value(value)
					else
					  if value.respond_to? :zset_score then
					    value.zset_score
				    else
  						raise UnindexableValue
						end
				end
			end
		
			private
				# Give me a float-representation of a string
				def string_value(string)
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