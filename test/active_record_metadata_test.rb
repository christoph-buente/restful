require File.dirname(__FILE__) + '/test_helper.rb'

context "active record metadata" do
  setup do
    Person.publish_to_api(:name, :pets => { :name, :species })
    Pet.publish_to_api(:person_id)
    
    @person = Person.create(:name => "Joe Bloggs", :current_location => "On the Toilet")
    @pet = @person.pets.create(:name => "Mietze", :species => "cat")
  end
  
  specify "should return link attributes from a model" do
    @pet.to_api.links.select { |node| node.name == "person_id" }.should.not.blank
  end
  
  specify "should return plain attributes from a model" do
    @pet.to_api.simple_attributes.select { |node| node.name == "name" }.should.not.blank
  end
  
  specify "should return collections attributes from a model" do
    @person.to_api.collections.select { |node| node.name == "pets" }.should.not.blank
  end
end