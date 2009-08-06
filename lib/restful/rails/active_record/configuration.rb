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
          #  by passing in something like @pet.to_restful(:name, :species).
          #
          def to_restful(config = self.class.restful_config)
            
            # convert to config object if not already one
            if config && !config.is_a?(Config)
              config = Config.new(config)
              config.merge!(self.class.restful_config) if !config.has_fields?
            end

            Restful::Converters::ActiveRecord.convert(self, config)
          end
          
          # simple method through which a model should know it's own name. override this where necessary. 
          def restful_url(url_base = Restful::Rails.api_hostname)
            "#{ url_base }#{ restful_path }"
          end
          
          def restful_path
            "/#{ self.class.to_s.tableize }/#{ self.to_param }"
          end
        end
        
        class Config # configures what attributes are exposed to the api. for a single resource. 
          attr_accessor :fields
          
          # set; eg :name, :pets => [:name, :species]
          def initialize(*fields)
            self.fields = [fields].flatten.compact
            self.fields += [{ :restful_options => {}}] unless Config.has_restful_options?(self.fields)
          end

          def expanded? # if nothing was set, this defaults to true. 
            restful_options[:expansion] != :collapsed
          end

          def whitelisted
            Config.remove_restful_options(@fields)
          end          
                    
          def has_fields?
            !self.whitelisted.empty?
          end
          
          def published?(key)
            @all_keys = self.whitelisted.map { |field| field.is_a?(Hash) ? field.keys : field }.flatten
            @all_keys.include?(key) if @all_keys
          end

          # replaces with another configuration object's fields
          def merge!(config)
            self.fields.unshift(*config.whitelisted)
            self.restful_options.merge! config.restful_options if config.restful_options
          end
          
          def nested?
            !!restful_options[:nested]
          end

          def nested(key)
            returning Config.new do |config|
              definition = @fields.select { |field| field.is_a?(Hash)  && field.keys.include?(key) }.first
              config.fields = definition[key] if definition
            end
          end

          def restful_options
            opts = self.fields.select { |el| el.is_a?(Hash) && el.keys.include?(:restful_options) }.first
            opts[:restful_options] if opts
          end
                    
          def has_restful_options?
            Config.has_restful_options?(self.fields)
          end
          
          def self.has_restful_options?(array)
            !array.select { |el| el.is_a?(Hash) && el[:restful_options] }.empty?
          end

          # removes restful_options from the end of the array if present, and returns a copy. non destructive. 
          def self.remove_restful_options(array)
            array.select { |el| !(el.is_a?(Hash) && el.keys.include?(:restful_options)) }
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Restful::Rails::ActiveRecord::Configuration