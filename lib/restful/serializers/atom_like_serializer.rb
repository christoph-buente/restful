require 'restful/serializers/base'
require 'builder'

#
#  Converts an APIModel to and from XML. 
#
module Restful
  module Serializers
    class AtomLikeSerializer < XMLSerializer
      
      serializer_name :atom_like
      
      # not xml_simple format. need to convert links. 
      def deserialize(xml, options = {})
        
      end
      
      protected
      
        def add_link_to(resource, builder, options = {})
          is_self = !!options[:self]
          builder.tag!("link", { :href => resource.url, :rel => (is_self ? "self" : resource.name) })
        end
        
        def root_element(resource)
          decorations = {}
          
          unless @nested_root
            decorations =  { :"xml:base" => Restful::Rails.api_hostname } unless Restful::Rails.api_hostname.blank?
            @nested_root = true
          end
          
         [ resource.name, decorations]
        end
        
        def decorations(value); {}; end
        def collections_decorations; {}; end
        def child_decorations(builder)
          super.merge!({ :include_xml_base => false })
        end
                
    end
  end
end