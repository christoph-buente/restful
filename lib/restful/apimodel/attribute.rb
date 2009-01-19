#
# Attribute model.
#
module Restful
  module ApiModel
    class Attribute
      attr_accessor :name, :value, :type
      
      def initialize(name, value)
        self.name = name
        self.value = value
        self.type = :simple_attribute
      end
    end
  end
end