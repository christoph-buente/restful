module Restful
  module Rails
    module ActiveRecord
      module Configuration
        def self.included(base)
          base.send :class_inheritable_accessor, :published
        
          base.published = []
        
          base.send :include, InstanceMethods
          base.extend(ClassMethods)
        end
        
        module ClassMethods
          def publish_to_api(*fieldnames) # declarative setter method
            self.published = fieldnames
          end
        end
    
        module InstanceMethods
          def to_api(attributes = self.class.published)
            Restful::Converters::ActiveRecord.convert(self, attributes)
          end
          
          # simple method through which a model should know it's own name. override 
          # this where necessary. 
          def resource_url(url_base = Restful::Rails.api_hostname)
            "#{ url_base }/#{ self.class.to_s.tableize }/#{ self.to_param }"
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Restful::Rails::ActiveRecord::Configuration