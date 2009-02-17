#
#  Converts an APIModel to and from a given format.  
#
module Restful
  module Serializers
    class Base
      cattr_accessor :serializers
      
      def serialize(resource, options = {}) # implement me. 
        raise NotImplementedError.new
      end
      
      def deserialize(resource, options = {}) # implement me. 
        raise NotImplementedError.new        
      end
      
      #
      #  Grabs a serializer, given...
      #
      #    .serialize_to(:xml, Resource.new(:animal => "cow"))
      #
      def self.serializer(type)
        serializers[type].new
      end
      
      def self.serializer_name(key)
        self.serializers ||= {}
        self.serializers[key] = self
      end
    end
  end
end