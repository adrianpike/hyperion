class Hyperion
	
  class HyperionException < Exception; end
  class NoKey < HyperionException; end

  def self.hyperion_defaults(defaults)
    class_variable_set(:@@redis_defaults, defaults)
  end
  
  def self.redis
    @@redis ||= Redis.new
  end

end