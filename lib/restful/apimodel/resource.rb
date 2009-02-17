#
#  Resource model. Something like a DOM model for the api. 
#
module Restful
  module ApiModel
    class Resource
      attr_accessor :url, :values, :name
      
      def initialize(url, name)
        self.url = url
        self.name = name
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
      def serialize_to(type)
        serializer = Restful::Serializers::Base.serializer(type)
        serializer.serialize(self)
      end
      
      # invoke deserialization
      def deserialize_from(type)
        serializer = Restful::Serializers::Base.serializer(type)
        serializer.deserialize(self)
      end
    end
  end
end