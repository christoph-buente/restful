module Restful
  module Rails
    module ActionController
      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
      end
    end
  end
end

ActionController::Base.send :include, Restful::Rails::ActionController