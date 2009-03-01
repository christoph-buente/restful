require 'restful/rails'
require 'restful/rails/active_record/configuration'
require 'restful/rails/active_record/metadata_tools'
require 'restful/rails/action_controller'
require 'restful/converters/active_record'
require 'restful/apimodel/resource'
require 'restful/apimodel/attribute'
require 'restful/apimodel/collection'
require 'restful/apimodel/link'
require 'restful/serializers/xml_serializer'
require 'restful/serializers/atom_like_serializer'
require 'restful/serializers/params_serializer'

module Restful
    
  MAJOR = 0
  MINOR = 1
  REVISION = 2
  VERSION = [MAJOR, MINOR, REVISION].join(".")
  
  #
  #  Restful.from_xml, #from_atom_like. Methods correspond with
  #  resgistered serializers. 
  #
  def self.method_missing(method, *args, &block)
    if method.to_s.match(/^from_(.*)$/)
      if serializer_clazz = Restful::Serializers::Base.serializers[type = $1.to_sym]
        s = serializer_clazz.new
        s.deserialize(args.first)
      else
        super
      end
    else
      super
    end
  end
end