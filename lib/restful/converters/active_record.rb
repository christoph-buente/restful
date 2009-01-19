#
#  Converts an ActiveRecord model into an ApiModel
#
#   TODO: finish this properly.
#
module Restful
  module Converters
    class ActiveRecord
      def self.convert(model, attributes)
        resource = Restful::ApiModel::Resource.new(model.resource_url)
        
        # Links
        resource.values += model.class.apiable_association_table.keys.map do |key|
          if model.published.include?(key.to_sym)
            url = model.resolve_association_resource_url(key)
            Restful::ApiModel::Link.new(key, url)
          end
        end.compact
        
        # Simple attributes
        # resource.simple_attributes += 
        
        # Collections
        
        resource
      end
    end
  end
end