#
# Attribute model.
# 
#   TODO: define this
#
module Restful
  module ApiModel
    class Collection < Attribute
      def initialize(name, value)
        super
        
        self.type = :collection
      end
    end
  end
end