require File.dirname(__FILE__) + '/../test_helper.rb'

context "active record metadata" do
  setup do
    Person.restful_publish(:name, :pets => [:name, :species])
    Pet.restful_publish(:person_id, :name) # person_id gets converted to a link automagically.
    
    @person = Person.create(:name => "Jimmy Jones", :current_location => "Under a tree")
    @pet = @person.pets.create(:name => "Mietze", :species => "cat")
  end
  
  teardown do
    reset_config
  end
  
  specify "should be able to convert a collection to an array of resources" do
    resources = Restful::Rails.tools.convert_collection_to_resources(@person, :pets, Restful.cfg)
    pet = resources.first

    resources.size.should.equal 1    
    pet.url.should.equal @pet.to_restful.url
  end
end