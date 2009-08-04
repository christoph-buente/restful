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
      t.integer :sex_id
      t.integer :haircut_id 
    end

    create_table :sexes do |t|
      t.string :sex
    end

    create_table :haircuts do |t|
      t.string :style
    end
  end
end

require plugin_root + '/init'
require 'models/pet'
require 'models/sex'
require 'models/person'
require 'models/haircut'

Restful::Rails.api_hostname = "http://example.com:3000"


# little convenience when starting irb: it executes some example object automatically:
if ENV['IRB_TEST_ENVIRONMENT']
  Person.restful_publish(:name, :current_location, :pets, :sex)
  Pet.restful_publish(:name, :person_id)
  Sex.restful_publish(:sex)

  @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
  @pet = @person.pets.create(:species => "cat")
  @sex = @person.sex = Sex.new(:sex => "male")
  @person.save!
  @haircut = @person.haircut = Haircut.new(:style => "fieser Scheitel")
  @xml_serializer = Restful::Serializers::XMLSerializer.new
  @params_serializer = Restful::Serializers::XMLSerializer.new
  @atom_like_serializer = Restful::Serializers::AtomLikeSerializer.new

  puts "You have the following objects available for playing around:"
  puts "@person, @pet, @sex, @haircut, @xml_serializer, @params_serializer, @atom_like_serializer" 
  puts 
  puts 
end


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
