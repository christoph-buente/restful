require 'restful/serializers/base'
require "rexml/document"
require 'builder'
require 'ruby-debug'

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
              if first_resource = resources.first
                xml.tag!(first_resource.name.pluralize, collections_decorations) do
                  resources.each do |resource|
                    serialize(resource,  { :instruct => false, :builder => xml })
                  end              
                end
              end
              
            elsif value.type == :link
              add_link_to(value, xml)
            elsif value.type == :resource
              serialize(value, {:instruct => false, :builder => xml})
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
          
          builder.tag!((is_self ? "restful-url" : transform_link_name(resource.name)), resource.full_url, :type => "link")
        end
      
        def add_tag(builder, value)
          string_value = case value.extended_type
          when :datetime
            value.value.xmlschema
          else
            value.value.to_s
          end
          
          builder.tag!(
            value.name.to_s.dasherize,
            string_value,
            decorations(value)
          )
        end
        
        def decorations(value)
          decorations = {}

          if value.extended_type == :binary
            decorations[:encoding] = 'base64'
          end

          if value.extended_type != :string and value.extended_type != :notype
            decorations[:type] = value.extended_type
          end

          if value.extended_type == :datetime
            decorations[:type] = :datetime
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
          resource = root_resource(node)
          
          node.elements.each do |el|
            type = calculate_node_type(el)
            resource.values << case type
            
            when :link : build_link(el, type)
            when :datetime
              Restful.attr(el.name, DateTime.parse(el.text), type)
            when :resource
              build_resource(el)
            when :array
              Restful.collection(el.name, el.elements.map { |child| build_resource(child) }, type)
            else 
              Restful.attr(el.name, el.text, type)
            end
          end

          resource
        end
        
        def calculate_node_type(el)
          if el.children.size > 1 && el.attributes["type"].blank? 
            return :resource
          else
            (el.attributes["type"] || "string").to_sym
          end
        end
        
        def build_link(el, type)
          Restful.link(revert_link_name(el.name), nil, el.text, type)
        end
        
        def root_resource(node)
          url = node.delete_element("restful-url").try(:text)
          Restful.resource(node.name, :url => url)
        end
    end
  end
end
