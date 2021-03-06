plugin_test = File.dirname(__FILE__)
plugin_root = File.join plugin_test, '..'
plugin_lib = File.join plugin_root, 'lib'

require 'rubygems'
require 'ruby-debug'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'test/spec'
require 'mocha'
require 'hpricot'
require 'xmlsimple'

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
      t.integer :age, :default => 10
      t.string :name
      t.integer :species
      t.integer :person_id
      
      t.timestamp :created_at
      t.timestamp :updated_at
    end

    create_table :people do |t|
      t.string :name
      t.string :current_location
      t.string :biography

      t.timestamp :created_at      
      t.timestamp :updated_at
    end

    create_table :wallets do |t|
      t.string :person_id
      t.string :contents
      
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end

require plugin_root + '/init'
require 'fixtures/models/pet'
require 'fixtures/models/wallet'
require 'fixtures/models/person'

Restful::Rails.api_hostname = "http://example.com:3000"

#
#  Helper methods
#
def reset_config
  Person.restful_config = Restful.cfg
  Pet.restful_config = Restful.cfg  
  Wallet.restful_config = Restful.cfg  
end

def xml_cmp a, b
  eq_all_but_zero = Object.new.instance_eval do
    def ==(other)
      Integer(other) == 0 ? false : true
    end
    self
  end
  a = XmlSimple.xml_in(a.to_s, 'normalisespace' => eq_all_but_zero) 
  b = XmlSimple.xml_in(b.to_s, 'normalisespace' => eq_all_but_zero) 
  a == b
end

# doing this tests that the content is the same regardless of attribute order etc. 
def xml_should_be_same(expected, actual)
  expected = Hpricot(expected)
  actual = Hpricot(actual)
  
  blame = "\n\n#################### expected\n#{expected.to_html}\n\n" "#################### actual:\n#{actual.to_html}\n\n" 
  (xml_cmp(expected, actual)).should.blaming(blame).equal true
end
