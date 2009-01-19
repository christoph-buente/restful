module Restful
  module Rails
    
    # sets the hostname for this request in a threadsafe manner. 
    def self.api_hostname=(hostname)
      Thread.current[:api_hostname] = hostname
    end
    
    # gets the hostname for the currently running thread. 
    def self.api_hostname
      Thread.current[:api_hostname]
    end
  end
end