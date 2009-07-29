require 'restful/serializers/base'
require 'builder'

#
#  AR params hash.
#
module Restful
  module Serializers
    class ParamsSerializer < Base
      
      serializer_name :params
      
      def serialize(resource, options = {})
        params = {}
        
        resource.values.each do |value|
          if value.type == :collection # serialize the stuffs
            resources = value.value
            name = resources.first.name.pluralize
            
            array = []
            resources.each do |resource|
              array << serialize(resource)
            end              
            
            params["#{value.name.to_sym}_attributes".to_sym] = array
          elsif value.type == :link
            params[value.name] = Restful::Rails::ActiveRecord::MetadataTools::Utils.dereference(value.value)
          elsif value.type == :resource
            params["#{value.name.to_sym}_attributes".to_sym] = serialize(value)
          else # plain ole
            params[value.name] = value.value
          end
        end
        
        params
      end
      
      # returns a resource, or collection of resources. 
      def deserialize(xml, options = {})
        
      end
    end
  end
end
