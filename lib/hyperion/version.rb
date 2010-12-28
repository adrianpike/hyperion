class Hyperion
	module Version #:nodoc:
		
		def branch; nil; end
		def major; 0;	end
		def minor; 2; end
		def patch; 0; end
		
		def version
			[branch,major,minor,patch].compact.collect(&:to_s).join('.')
		end
		
		def version_compatible?(old_version)
			versions = old_version.split('.').collect{|i| i.to_i }
			
			if versions.size > 3 then
			  branch,major,minor,patch = versions
		  else
		    major,minor,patch = versions
	    end
			
			return false if (major==0 and minor < 2)
			
			true
		end
		
		# TODO: store the version _and_ the DB config (including shard strategy) within the Redis store
		
	end
end