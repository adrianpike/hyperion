class Hyperion
	module Indices
		
	  class NoIndex < HyperionException; end
	  class UnindexableValue < HyperionException; end

		def hyperion_index(index)
	    if class_variable_defined?(:@@redis_indexes) then
	      class_variable_set(:@@redis_indexes, class_variable_get(:@@redis_indexes) << index)
	    else
	      class_variable_set(:@@redis_indexes, [index])
	    end
	  end

		def reindex!
			# TODO
		end
		
		# Indexes need to be sorted sets!
		# ZSET scores can supposedly be large floats, should explore max ZSET score size.
		# We can sort on Integers,
		
		
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
		
		def score(value)
			case value
				when Float,Fixnum,Bignum
					value
				when String
					string_value(value)
				else
					raise UnindexableValue
			end
		end
		
	end
end