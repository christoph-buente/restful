require File.dirname(__FILE__) + '/test_helper.rb'

context "active record models" do
  setup do
    Person.restful_publish(:name, :pets => [:name, :species])
    @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
    @pet = @person.pets.create(:name => "Mietze", :species => "cat")
  end
  
  teardown do
    reset_config
  end
   
  specify "should be able to convert themselves to an apimodel containing all and only the attributes exposed by Model.publish_api" do    
    @person.to_api.simple_attributes.select { |node| node.name == :name }.should.not.blank
    @person.to_api.simple_attributes.select { |node| node.name == :current_location }.should.blank
  end
  
  specify "should be able to override to_api published fields by passing them into the method" do
    api = @person.to_api(:pets)

    api.simple_attributes.should.blank?
    api.collections.map { |node| node.name }.sort.should.equal [:pets]
  end
end