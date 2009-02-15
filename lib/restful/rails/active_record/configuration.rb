#
#  Configuration options for restful. 
#
module Restful
  module Rails
    module ActiveRecord
      module Configuration
        def self.included(base)
          base.send :class_inheritable_accessor, :restful_config
          base.restful_config = Config.new
          base.send :include, InstanceMethods
          base.extend(ClassMethods)
        end
        
        module ClassMethods
          
          #
          #  In the form: 
          #
          #    Person.restful_publish(:name, :pets => [:name, :species])
          #
          #  If pet already has configured the api with restful_publish, you would
          #  get the default nested attributes. In the above example, these would be
          #  overriden. 
          #
          def restful_publish(*fieldnames) # declarative setter method
            self.restful_config.fields = fieldnames
          end
        end
    
        module InstanceMethods
          
          #
          #  converts this AR object to an apimodel object. per default, only the
          #  attributes in self.class.restful_config are shown. this can be overriden
          #  by passing in something like @pet.to_api(:name, :species).
          #
          def to_api(attributes = self.class.restful_config)
            
            # convert to config object if not already one
            if attributes && !attributes.is_a?(Config)
              attributes = Config.new(attributes)
            end
            
            Restful::Converters::ActiveRecord.convert(self, attributes)
          end
          
          # simple method through which a model should know it's own name. override 
          # this where necessary. 
          def resource_url(url_base = Restful::Rails.api_hostname)
            "#{ url_base }/#{ self.class.to_s.tableize }/#{ self.to_param }"
          end
        end
        
        # configures what attributes are exposed to the api. 
        class Config
          attr_accessor :fields
          
          # set; eg :name, :pets => [:name, :species]
          def initialize(fields = [])
            self.fields = [fields].flatten.compact
          end
          
          def published?(key)
            @all_keys = self.fields.map { |field| field.is_a?(Hash) ? field.keys : field }.flatten
            @all_keys.include?(key) if @all_keys
          end
          
          def nested(key)
            definition = @fields.select { |field| field.is_a?(Hash)  && field.keys.include?(key) }.first

            if definition
              config = Config.new
              config.fields = definition[key]
              config
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Restful::Rails::ActiveRecord::Configuration