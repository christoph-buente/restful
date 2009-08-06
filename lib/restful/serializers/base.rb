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
      #    .serialize(:xml, Resource.new(:animal => "cow"))
      #
      def self.serializer(type)
        serializers[type].new
      end
      
      def self.serializer_name(key)
        self.serializers ||= {}
        self.serializers[key] = self
      end
      
      protected
        def transform_link_name(name)
          name.to_s.gsub /_id$/, "-restful-url"
        end
      
        def revert_link_name(name)
          name.to_s.gsub /-restful-url$/, "_id"
        end      
    end
  end
end