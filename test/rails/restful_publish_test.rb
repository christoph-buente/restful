require File.dirname(__FILE__) + '/../test_helper.rb'

context "restful publish" do
  teardown do
    reset_config
  end
   
  specify "should result in a method .published?(:attr_key) return true for published attributes" do
    Pet.restful_publish(:person_id, :name) # person_id gets converted to a link automagically.
    
    Pet.restful_config.published?(:name).should.equal true
    Pet.restful_config.published?(:pets).should.equal false
    Pet.restful_config.published?(:species).should.equal false
  end
  
  specify "should have restful_options as an empty hash after calling restful_publish" do
    Person.restful_publish(:name, :pets => [:name, :species])
    Person.restful_config.restful_options.should.==({})
  end
end

context "api publishing with nesting" do
  teardown do
    reset_config
  end
 
  specify "should result in a method .published?(:attr_key) return true for nested attributes" do
    Person.restful_publish(:name, :pets => [:name, :species])
    Person.restful_config.published?(:pets).should.equal true
  end
  
  specify "should be invoke to_restful on the nested model with the specified nested attributes" do
    Person.restful_publish(:name, :pets => [:name, :species])    
    @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
    @pet = @person.pets.create(:name => "Mietze", :species => "cat")
    
    Pet.any_instance.expects(:to_restful).with { |arg| arg.whitelisted == [:name, :species] }
    @person.to_restful
  end
end

