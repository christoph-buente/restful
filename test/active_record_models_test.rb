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
    resource = @person.to_restful
    
    resource.simple_attributes.select { |node| node.name == :name }.should.not.blank
    resource.simple_attributes.select { |node| node.name == :current_location }.should.blank

    mietze = @person.to_restful.collections .select { |node| node.name == :pets }.first.value.first
    mietze.simple_attributes.size.should.== 2
    mietze.simple_attributes.select { |node| node.name == :name }.should.not.blank
    mietze.simple_attributes.select { |node| node.name == :species }.should.not.blank
  end

  specify "should be able to convert themselves to an apimodel containing all and only the attributes exposed by Model.publish_api. this holds true if to_restful is called with some configuration options. " do    
    resource = @person.to_restful(:restful_options => { :nested => false })
    resource.simple_attributes.select { |node| node.name == :name }.should.not.blank
    resource.simple_attributes.select { |node| node.name == :current_location }.should.blank

    mietze = resource.collections .select { |node| node.name == :pets }.first.value.first
    mietze.simple_attributes.size.should.== 2
    mietze.simple_attributes.select { |node| node.name == :name }.should.not.blank
    mietze.simple_attributes.select { |node| node.name == :species }.should.not.blank
  end
  
  specify "should be able to override to_restful published fields by passing them into the method" do
    api = @person.to_restful(:pets)

    api.simple_attributes.should.blank?
    api.collections.map { |node| node.name }.sort.should.equal [:pets]
  end
end