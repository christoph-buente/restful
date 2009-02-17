require 'builder'

#
#  Converts an APIModel to and from XML. 
#
module Restful
  module Serializers
    class XMLSerializer < Base
      
      def serialize(resource, options = {})
        xml = options[:builder] || Builder::XmlMarkup.new(:indent => 2)
        xml.instruct! unless options[:instruct].is_a?(FalseClass)
        
        xml.tag!(resource.name) do
          add_link_to(resource, xml, :self => true)
                    
          resource.values.each do |value|
            if value.type == :collection # serialize the stuffs
              resources = value.value
              
              xml.tag!(resources.first.name.pluralize, :type => "array") do
                resources.each do |resource|
                  serialize(resource, { :instruct => false, :builder => xml })
                end              
              end
              
            else # plain ole
              add_tag(xml, value)
            end
          end
        end       
      end
      
      def deserialize
        # doit
      end
      
      protected
        def add_link_to(resource, builder, options = {})
          builder.tag!("resource_url", resource.url, :type => "link")
        end
      
        def add_tag(builder, value)
          decorations = {}

          if value.extended_type == :binary
            decorations[:encoding] = 'base64'
          end

          if value.extended_type != :string
            decorations[:type] = type
          end

          if value.value.nil?
            decorations[:nil] = true
          end

          builder.tag!(
            value.name.to_s.dasherize,
            value.value.to_s,
            decorations
          )
        end
    end
  end
end