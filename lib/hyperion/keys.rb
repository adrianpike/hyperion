class Hyperion
	module Keys
	
	  def hyperion_key(key, opts = {})
	    class_variable_set(:@@redis_key, key)
	    class_variable_set(:@@redis_generate_key, opts[:generate])
	  end
		
	end
end