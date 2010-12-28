class Hyperion

	DEFAULTS = {
	  :host => '127.0.0.1',
	  :port => '6379'
	}
	
	# All hyperion Exceptions get wrapped under this beauty. You'll see such fine exceptions as:
	# - NoIndex - You tried to query an attribute that isn't indexed.
	# - ConnectionRefused - Hyperion wasn't able to connect to your Redis backend.
	# - UnindexableValue - You're like, uh, trying to index a tomato or something. 
	#   I'm not sure what kind of hueristic we should use for Tomato indexing, but by golly go take a looksee at Indices#121, and you can make your own hueristic!
  class HyperionException < Exception; end
  class ConnectionRefused < HyperionException #:nodoc:
  end
	
  def self.hyperion_defaults(defaults)
    attribute_defaults(defaults)
  end
  def self.attribute_defaults(defaults)
    class_variable_set(:@@attr_defaults, defaults)
  end
  
  # TODO: refactor Hyperion's config - investigate AR
  def self.config(attrib)
    DEFAULTS[attrib]
  end
  
  def self.redis(fetch_config = true)
    unless class_variable_defined?('@@redis') then
			begin
			  @@redis = Redis.new(:host => config(:host), :port => config(:port))
			rescue Errno::ECONNREFUSED => e
			  Hyperion.logger.error("Hyperion wasn't able to connect to your Redis server on #{config(:host)}:#{config(:port)}.")
        raise ConnectionRefused
			end
		end
		if fetch_config and not class_variable_defined?('@@db_config') then
		  @@db_config = load_db_config
		end
	  
		@@redis
  end
  
  def self.load_db_config
    old_version = @@redis['hyperion_version']
	  Hyperion.logger.error("Hyperion datastore version #{old_version} is INCOMPATIBLE with your current hyperion gem. We'll still continue, but beware that things might not work right! Read MIGRATION for more info.") if old_version==nil or not version_compatible?(old_version)
	  unless old_version then
		  @@redis['hyperion_version'] = version
	  end
	  
	  {
	    :version => version
	  }
  end

  def self.attr_accessor(*args)
    attribute(*args)
  end
  
  def self.attribute(*args)
    args.each{|attr|
      Hyperion.logger.debug("[Hyperion] Initializing attribute #{attr} on #{self.to_s}")
      module_eval( "def #{attr}() @#{attr}; end" )
      module_eval( "def #{attr}=(val) @#{attr} = val; end" )
    }
  end

  def save
    if defined?(:_run_save_callbacks) then
      _run_save_callbacks do
  		  save_without_callbacks
      end
    else
      save_without_callbacks
    end
    
    @persisted = true
  end
  
  def save_without_callbacks #:nodoc:
    rekey

    Hyperion.logger.debug("[Hyperion] Saving into #{full_key}: #{self.inspect}")
    Hyperion.redis[full_key] = self.serialize
  
    reindex!
  end

	def delete
		reindex!(:unstore => true)
		
	  Hyperion.logger.debug("[Hyperion] Removing from #{full_key}")
    Hyperion.redis[full_key] = nil
    
    @destroyed = true
	end

  def initialize(opts = {})
    defaults = (self.class.class_variable_defined?('@@attr_defaults') ? self.class.class_variable_get('@@attr_defaults') : {})

    defaults.merge(opts).each {|k,v|
      self.send(k.to_s+'=',v)
    }
  end

  def self.deserialize(what)
    obj = YAML.load(what)
    obj.remember_initial_values
    
    obj
  end
  def serialize; YAML::dump(self); end

  def self.dump(output = STDOUT, lock = false)
    # TODO: lockability and progress
    output.write(<<-eos)
# Hyperion Dump
# Generated by @adrianpike's Hyperion gem.
    eos
    output.write('# Generated on ' + Time.current.to_s + "\n")
    output.write('# DB size is ' + redis.dbsize.to_s + "\n")

    redis.keys.each{|k|
      case redis.type(k)
      when "string"
        output.write({ k => redis.get(k)}.to_yaml)
      when "set"
        output.write({ k => redis.smembers(k) }.to_yaml)
      end
    }
  end


  # THIS IS MAD DANGEROUS AND UNTESTED, BEWARE DATA INTEGRITY
  def self.load(file = STDIN, truncate = true, lock = false)
    # TODO: lockability and progress    

    YAML.each_document( file ) do |ydoc|
      ydoc.each {|k,v|
        redis.del(k) if truncate

        case v.class.to_s
          when 'String'
            redis[k] = v
          when 'Array'
            v.each{|val|
              redis.sadd(k,val)
            }
          else
            p v.class
        end
      }
    end

  end

  # THIS IS TOTALLY IRREVERSIBLE YO
  def self.truncate!
    redis.flushdb
  end

end