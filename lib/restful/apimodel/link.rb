#
#  Link model.
#
module Restful
  module ApiModel
    class Link < Attribute
      def initialize(name, value, extended_type)
        super
        
        self.type = :link
      end
    end
  end
end