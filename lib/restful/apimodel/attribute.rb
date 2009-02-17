#
#  Attribute model.
#
module Restful
  module ApiModel
    class Attribute
      attr_accessor :name, :value, :type, :extended_type
      
      def initialize(name, value, extended_type)
        self.name = name
        self.value = value
        self.extended_type = extended_type
        self.type = :simple_attribute
      end
    end
  end
end