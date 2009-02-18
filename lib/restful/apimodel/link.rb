#
#  Link model.
#
module Restful
  module ApiModel
    class Link < Attribute
      attr_accessor :base, :path
      
      def initialize(name, base, path, extended_type)        
        self.base = base
        self.path = path        
        super(name, self.url, extended_type)
        self.type = :link
      end
      
      def url
        base.blank? ? path : "#{ base }/#{ path }"
      end
    end
  end
end