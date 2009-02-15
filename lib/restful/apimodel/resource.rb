#
#  Resource model. Something like a DOM model for the api. 
#
module Restful
  module ApiModel
    class Resource
      attr_accessor :url, :values
      
      def initialize(url)
        self.url = url
        self.values = []
      end
      
      def links
        values.select { |attribute| attribute.type == :link }
      end
      
      def simple_attributes
        values.select { |attribute| attribute.type == :simple_attribute }        
      end
      
      def collections
        values.select { |attribute| attribute.type == :collection }
      end
    end
  end
end