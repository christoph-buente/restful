#
#  Converts an APIModel to and from a given format.  
#
module Restful
  module Serializers
    class Base
      
      def serialize # implement me. 
        raise NotImplementedError.new
      end
      
      def deserialize # implement me. 
        raise NotImplementedError.new        
      end
      
      #
      #  Grabs a serializer, given...
      #
      #    .serialize_to(:xml, Resource.new(:animal => "cow"))
      #
      def self.serializer(type)
        
        case type
        when :xml : XMLSerializer.new
        when :atom_like : AtomLikeSerializer.new
        end
      end
    end
  end
end