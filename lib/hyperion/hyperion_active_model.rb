class Hyperion
  module HyperionActiveModel #:nodoc:
    
    def to_model
      self
    end
    
    def to_key
      [self.send(self.class.class_variable_get('@@redis_key'))] if self.persisted?
    end
    
    def errors
      # TODO
      obj = Object.new
      def obj.[](key) end
      def obj.full_messages() [] end
      obj
    end
    
    def valid?
      # TODO
    end
    def new_record?
      @initial_values == nil
    end
    def destroyed?
      @destroyed == true
    end
    def persisted?
      @persisted == true
    end

    def to_param
      self.to_key if self.persisted?
    end

    def self.included(where)
      where.extend ClassMethods
      where.extend ActiveModel::Callbacks
      where.extend ActiveModel::Validations
      where.extend ActiveModel::Naming
      
      where.define_model_callbacks :save, :delete
    end
    
    module ClassMethods #:nodoc:
      def model_name
        ActiveModel::Name.new(self)
      end
    end
    
  end
end