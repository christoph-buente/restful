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
            cache_association_resource_url_metadata
            apiable_shadow_link_attributes(self)
          end

          def cache_association_resource_url_metadata
            self.apiable_associations ||= (self.reflect_on_all_associations(:belongs_to) + self.reflect_on_all_associations(:has_one)).flatten.uniq
            self.apiable_association_table ||= self.apiable_associations.inject({}) { |memo, reflection| memo[reflection.primary_key_name] = reflection; memo }
          end
          
          #
          # creates an attribute named <association name>-resource-url which 'shadows'
          # the actual attribute (is available on the model as an attribute)
          #
          def apiable_shadow_link_attributes(clazz)
            clazz.apiable_association_table.keys.each do |ass_key|
              clazz.send :define_method, "#{ MetadataTools::Utils::transform_link_name(ass_key) }=" do |value|
                self.send("#{ ass_key }=", dereference(value))
              end
            end
          end
        end
        
        module InstanceMethods
          def resolve_association_resource_url(association_key_name)
            self.class.cache_association_resource_url_metadata

            if reflection = self.class.apiable_association_table[association_key_name]
              related_resource = self.send(reflection.name)
              related_resource ? related_resource.resource_url : ""
            end
          end
        end

        module  Utils
          def self.dereference(url)
            m, resource, params = *url.match(Regexp.new("#{ Restful::Rails.api_hostname }\/(.*)\/(.*)"))

            resource = if resource && params
              clazz = resource.try(:singularize).try(:camelize).try(:constantize)
              clazz.find_by_param(params) if clazz 
            end

            resource ? resource.id : 0
          end
          
          def self.transform_link_name(name)
            name.gsub /_id$/, "_resource_url"
          end
          
          # retruns non association / collection attributes. 
          def self.simple_attributes_on(model)
            attributes = model.attributes
            
            attributes.delete_if do |k, v|
              model.class.apiable_association_table.keys.include?(k)
            end
          end
          
          # takes an ar model and a key like :people, and returns an array of resources. 
          def self.convert_collection_to_resources(model, key, config = nil)
            
            # load the associated objects. 
            # TODO: SHOULD not load the entire association, only the published attributes. 
            models = model.send(key)
            
            # convert them to_api. 
            models.map do |m|
              config ? m.to_api(config) : m.to_api
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Restful::Rails::ActiveRecord::MetadataTools