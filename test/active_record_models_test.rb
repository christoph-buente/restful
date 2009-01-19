require File.dirname(__FILE__) + '/test_helper.rb'

context "active record models" do
  setup do
    Person.publish_to_api(:name, :pets => { :name, :species })
    @person = Person.create(:name => "Joe Bloggs", :current_location => "On the Toilet")
    @pet = @person.pets.create(:name => "Mietze", :species => "cat")
  end
  
  specify "should be able to convert themselves to an api model containing all and only the attributes exposed by Model.publish_api" do    
    @person.to_api.simple_attributes.select { |node| node.name == "name" }.should.not.blank
    @person.to_api.simple_attributes.select { |node| node.name == "current_location" }.should.blank
  end
end