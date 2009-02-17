plugin_test = File.dirname(__FILE__)
plugin_root = File.join plugin_test, '..'
plugin_lib = File.join plugin_root, 'lib'

require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'test/spec'
require 'mocha'
require 'hpricot'

$:.unshift plugin_lib, plugin_test

RAILS_ENV = "test"
RAILS_ROOT = plugin_root # fake the rails root directory.

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::ERROR
ActiveRecord::Base.colorize_logging = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile  => ":memory:")

silence_stream(STDOUT) do
  ActiveRecord::Schema.define do
    create_table :pets do |t|
      t.string :name
      t.integer :species
      t.integer :person_id
    end

    create_table :people do |t|
      t.string :name
      t.string :current_location
    end
  end
end

require plugin_root + '/init'
require 'models/pet'
require 'models/person'

Restful::Rails.api_hostname = "http://example.com:3000"

#
#  Helper methods
#
def reset_config
  Person.restful_config = Restful::Rails::ActiveRecord::Configuration::Config.new
  Pet.restful_config = Restful::Rails::ActiveRecord::Configuration::Config.new  
end

# doing this tests that the content is the same regardless of attribute order etc. 
def xml_should_be_same(expected, actual)
  (Hpricot(expected).to_html == Hpricot(actual).to_html).should.equal true
end