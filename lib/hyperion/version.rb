class Hyperion
	module Version
		
		def branch; nil; end
		def major; 0;	end
		def minor; 1; end
		def patch; 0; end
		
		def version
			[branch,major,minor,patch].compact.collect(&:to_s).join('.')
		end
		
	end
end