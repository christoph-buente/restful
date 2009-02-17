#
#  Collection model. A collection is a named array of Resources. 
#
module Restful
  module ApiModel
    class Collection < Attribute
      def initialize(name, resources, extended_type)
        super
        
        self.type = :collection
      end
    end
  end
end