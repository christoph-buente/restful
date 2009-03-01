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
              
            elsif value.type == :link
              add_link_to(value, xml)
            else # plain ole
              add_tag(xml, value)
            end
          end
        end       
      end
      
      # returns a resource, or collection of resources. 
      def deserialize(xml, options = {})
        build_resource(REXML::Document.new(xml).root)
      end
      
      protected
      
        def add_link_to(resource, builder, options = {})
          is_self = !!options[:self]
          
          builder.tag!((is_self ? "restful-url" : transform_link_name(resource.name)), resource.url, :type => "link")
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
        
        # turns a rexml node into a Resource
        def build_resource(node)
          resource = Restful::ApiModel::Resource.new(node.name, :url => node.delete_element("restful-url").try(:text))
          
          node.elements.each do |el|
            type = (el.attributes["type"] || "string").to_sym
            resource.values << case type
            
            when :link : Restful::ApiModel::Link.new(revert_link_name(el.name), nil, el.text, type)
            when :array
              Restful::ApiModel::Collection.new(el.name, el.elements.map { |child| build_resource(child) }, type)
            else 
              Restful::ApiModel::Attribute.new(el.name, el.text, type)
            end
          end

          resource
        end
    end
  end
end