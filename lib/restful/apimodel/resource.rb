#
#  Resource model. Something like a DOM model for the api. 
#
module Restful
  module ApiModel
    class Resource
      attr_accessor :base, :path, :url, :values, :name, :type
      
      def initialize(name, url)
        self.url = url[:url]
        self.path = url[:path]
        self.base = url[:base]                
        self.name = name
        self.type = :resource
        self.values = []
      end
      
      def links
        values.select { |attribute| attribute.type == :link }
      end
      
      def simple_attributes
        values.select { |attribute| attribute.type == :simple_attribute }        
      end
      
      def collections
        values.select { |attribute| attribute.type == :collection }
      end
      
      # invoke serialization
      def serialize(type)
        serializer = Restful::Serializers::Base.serializer(type)
        serializer.serialize(self)
      end
      
      # invoke deserialization
      def deserialize_from(type)
        serializer = Restful::Serializers::Base.serializer(type)
        serializer.deserialize(self)
      end
      
      def full_url
        base.blank? ? url : "#{ base }#{ path }"
      end
    end
  end
end
