class Hyperion
	module Version #:nodoc:
		
		def branch; nil; end
		def major; 0;	end
		def minor; 1; end
		def patch; 0; end
		
		def version
			[branch,major,minor,patch].compact.collect(&:to_s).join('.')
		end
		
		def version_compatible?(old_version)
			true # I haven't broken it yet.
		end
		
		# TODO: store the version and the DB config (including shard strategy) within the Redis store
		
	end
end