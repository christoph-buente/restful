require File.dirname(__FILE__) + '/test_helper.rb'

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
    resources = Restful::Rails::ActiveRecord::MetadataTools::Utils.convert_collection_to_resources(@person, :pets)
    pet = resources.first

    resources.size.should.equal 1    
    pet.url.should.equal @pet.to_api.url
  end

  specify "should return link attributes from a model" do
    @pet.to_api.links.map { |node| node.name }.sort.should.equal [:person_id]
  end
  
  specify "should return plain attributes from a model" do
    @pet.to_api.simple_attributes.map { |node| node.name }.sort.should.equal [:name]
  end
  
  specify "should return collections attributes from a model" do
    @person.to_api.collections.map { |node| node.name }.sort.should.equal [:pets]
  end
end