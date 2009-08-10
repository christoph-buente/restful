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
            self.restful_config = Restful.cfg(*fieldnames)
          end
        end
    
        module InstanceMethods
          
          #
          #  converts this AR object to an apimodel object. per default, only the
          #  attributes in self.class.restful_config are shown. this can be overriden
          #  by passing in something like @pet.to_restful(:name, :species).
          #
          def to_restful(config = self.class.restful_config)

            if config && !config.is_a?(Config)
             config = Config.new(config)
            end
            
            config.whitelisted = self.class.restful_config.whitelisted if config.whitelisted.empty?
            
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
          
          attr_accessor :whitelisted, :restful_options
          
          def initialize(*fields) # set; eg :name, :pets => [:name, :species]
            @whitelisted, @restful_options = split_into_whitelist_and_restful_options([fields].flatten.compact)
          end

          def published?(key)
            @whitelisted.include?(key) || !!@whitelisted.select { |field| field.is_a?(Hash)  && field.keys.include?(key) }.first
          end

          def expanded? # if nothing was set, this defaults to true. 
            @restful_options[:expansion] != :collapsed
          end       

          def nested?
            !!restful_options[:nested]
          end

          def nested(key)
            definition = @whitelisted.select { |field| field.is_a?(Hash)  && field.keys.include?(key) }.first
            Config.new((definition[key] if definition))
          end

          private
          
            def split_into_whitelist_and_restful_options(array)
              options = {}
        
              return array.map do |el|
                if el.is_a? Hash
                  el = el.clone
                  deleted = el.delete(:restful_options) 
                  options.merge!(deleted) if deleted
                  el = nil if el == {}
                end
              
                el
              end.compact, options
            end
            
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Restful::Rails::ActiveRecord::Configuration