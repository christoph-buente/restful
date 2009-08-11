require 'restful/serializers/base'
require 'builder'

#
#  Converts an APIModel to and from XML. 
#
module Restful
  module Serializers
    class AtomLikeSerializer < XMLSerializer
      
      serializer_name :atom_like
      
      protected
        
        def root_resource(node)
          url_base = node.attribute(:base, :xml)
          me_node = node.delete_element("link[@rel='self']")
          own_url = me_node.attribute(:href)
          Restful.resource(node.name, :path => own_url, :base => url_base)
        end
      
        def build_link(el, type)
          Restful.link(revert_link_name(el.attribute('rel')), nil, el.attribute('href'), type)
        end
        
        def calculate_node_type(el)
          return :link if el.name.downcase == "link"
          (el.attributes["type"] || "string").to_sym
        end
                
        def add_link_to(resource, builder, options = {})
          is_self = !!options[:self]
          builder.tag!("link", { :href => resource.path, :rel => (is_self ? "self" : resource.name) })
        end
        
        def root_element(resource)
          decorations = {}
          
          unless @nested_root
            decorations =  { :"xml:base" => Restful::Rails.api_hostname } unless Restful::Rails.api_hostname.blank?
            @nested_root = true
          end
          
          [resource.name, decorations]
        end
        
        def decorations(value); {}; end
        def collections_decorations; {}; end                
    end
  end
end