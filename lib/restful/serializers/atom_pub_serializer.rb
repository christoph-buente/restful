require 'builder'

#
#  Converts an APIModel to and from XML. 
#
module Restful
  module Serializers
    class AtomPubSerializer < XMLSerializer
      
      protected
        def add_link_to(resource, builder, options = {})
          is_self = !!options[:self]
          builder.tag!("link", { :href => resource.url, :rel => (is_self ? "self" : resource.name) })
        end
    end
  end
end