#
#  Handle ActiveRecord associations and such like. 
#
module Restful
  module Rails
    module ActiveRecord
      module MetadataTools
        
        def self.included(base)
          base.class_inheritable_accessor :apiable_associations
          base.class_inheritable_accessor :apiable_association_table
        
          base.send :include, InstanceMethods
          base.extend(ClassMethods)
        end
        
        module ClassMethods
          
          def apiable
            cache_association_restful_url_metadata
          end

          def cache_association_restful_url_metadata
            self.apiable_associations ||= (self.reflect_on_all_associations(:belongs_to) + self.reflect_on_all_associations(:has_one)).flatten.uniq
            self.apiable_association_table ||= self.apiable_associations.inject({}) { |memo, reflection| memo[reflection.primary_key_name] = reflection; memo }
          end
          
          def find_by_restful(id)
            find(id)
          end
        end
        
        module InstanceMethods
          def resolve_association_restful_url(association_key_name)            
            self.class.cache_association_restful_url_metadata

            if reflection = self.class.apiable_association_table[association_key_name]
              related_resource = self.send(reflection.name)
              [Restful::Rails.api_hostname, related_resource.restful_path] if related_resource
            end
          end
        end

        module  Utils
          
          # called for nested resources. 
          def self.expand(resource, config)
            config.restful_options[:nested] = true
            resource.to_restful(config)
          end

          def self.link(key, model, config)
            Restful.link(key.to_sym, "base", "path", "link")
          end
          
          def self.dereference(url)
            regexp = Regexp.new("#{ Restful::Rails.api_hostname }\/(.*)\/(.*)")
            m, resource, params = *url.match(regexp)
            resource = if resource && params
              clazz = resource.try(:singularize).try(:camelize).try(:constantize)
              clazz.find_by_restful(params) if clazz 
            end

            resource ? resource.id : 0
          end
          
          # retruns non association / collection attributes. 
          def self.simple_attributes_on(model)
            attributes = model.attributes
            
            attributes.delete_if do |k, v|
              model.class.apiable_association_table && model.class.apiable_association_table.keys.include?(k)
            end
          end
          
          #
          #  Takes an ar model and a key like :people, and returns an array of resources. 
          #  
          #   TODO: don't load the entire association, only the published attributes (with an appropriate :select). 
          #   TODO: get some pagination in.
          #
          def self.convert_collection_to_resources(model, key, config)
            
            # load the associated objects.
            models = model.send(key)
            
            # convert them to_restful. 
            if models
              [*models].map do |m| 
                if m.respond_to? :to_restful
                  config.nested? ?
                    link(key, m, config) :
                    expand(m, config)
                else
                  raise "Seems as if you want to export the relation #{ key } of an #{ model.class.to_s } object without making #{ key } apiable."
                end
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Restful::Rails::ActiveRecord::MetadataTools