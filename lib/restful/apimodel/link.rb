#
#  Link model.
#
module Restful
  module ApiModel
    class Link < Attribute
      def initialize(name, value)
        super
        
        self.type = :link
      end
    end
  end
end