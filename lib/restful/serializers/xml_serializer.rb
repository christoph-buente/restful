require 'restful/serializers/base'
require 'builder'

#
#  Converts an APIModel to and from XML. 
#
module Restful
  module Serializers
    class XMLSerializer < Base
      
      serializer_name :xml
      
      def serialize(resource, options = {})
        xml = options[:builder] || Builder::XmlMarkup.new(:indent => 2)
        xml.instruct! unless options[:instruct].is_a?(FalseClass)
        
        xml.tag!(*root_element(resource)) do
          add_link_to(resource, xml, :self => true)
                    
          resource.values.each do |value|
            if value.type == :collection # serialize the stuffs
              resources = value.value
              
              xml.tag!(resources.first.name.pluralize, collections_decorations) do
                resources.each do |resource|
                  serialize(resource,  { :instruct => false, :builder => xml })
                end              
              end
              
            else # plain ole
              add_tag(xml, value)
            end
          end
        end       
      end
      
      # follows xml_simple, so we can deserialize with that.
      def deserialize(xml, options = {})
        Hash.from_xml(xml)
      end
      
      protected
      
        def add_link_to(resource, builder, options = {})
          builder.tag!("resource_url", resource.url, :type => "link")
        end
      
        def add_tag(builder, value)
          builder.tag!(
            value.name.to_s.dasherize,
            value.value.to_s,
            decorations(value)
          )
        end
        
        def decorations(value)
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
          
          decorations
        end
        
        def collections_decorations
          { :type => "array" }
        end
        
        def root_element(resource, options = {})
          [resource.name]
        end
    end
  end
end