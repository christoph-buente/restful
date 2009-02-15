#
#  Converts an ActiveRecord model into an ApiModel
#
module Restful
  module Converters
    class ActiveRecord
      def self.convert(model, attributes)
        resource = Restful::ApiModel::Resource.new(model.resource_url)
        
        # Links
        resource.values += model.class.apiable_association_table.keys.map do |key|
          if attributes.published?(key.to_sym)
            url = model.resolve_association_resource_url(key)
            Restful::ApiModel::Link.new(key.to_sym, url)
          end
        end.compact
                
        # Simple attributes
        resource.values += Restful::Rails::ActiveRecord::MetadataTools::Utils.simple_attributes_on(model).map do |attribute|
          key, value = attribute
          
          if attributes.published?(key.to_sym)
            Restful::ApiModel::Attribute.new(key.to_sym, value)
          end
        end.compact
                
        # Collections
        resource.values += model.class.reflections.keys.map do |key|
          if attributes.published?(key.to_sym)
      
            # grab the associated resource(s) and run them through conversion
            resources = Restful::Rails::ActiveRecord::MetadataTools::Utils.convert_collection_to_resources(model, key, attributes.nested(key.to_sym))
            Restful::ApiModel::Collection.new(key.to_sym, resources)
          end
        end.compact
        
        resource
      end
    end
  end
end