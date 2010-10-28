class Hyperion
	module Indices
		
	  class NoIndex < HyperionException; end

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
		
	end
end