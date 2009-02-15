require File.dirname(__FILE__) + '/test_helper.rb'

context "api publishing" do
  specify "should result in a method .published?(:attr_key) return true for published attributes" do
    Pet.restful_publish(:person_id, :name) # person_id gets converted to a link automagically.
    
    Pet.restful_config.published?(:name).should.equal true
    Pet.restful_config.published?(:pets).should.equal false
    Pet.restful_config.published?(:species).should.equal false
  end
end

context "api publishing with nesting" do
  specify "should result in a method .published?(:attr_key) return true for nested attributes" do
    Person.restful_publish(:name, :pets => [:name, :species])
    
    Person.restful_config.published?(:pets).should.equal true
  end
  
  specify "should be invoke to_api on the nested model with the specified nested attributes" do
    Person.restful_publish(:name, :pets => [:name, :species])    
    @person = Person.create(:name => "Joe Bloggs", :current_location => "On the Toilet")
    @pet = @person.pets.create(:name => "Mietze", :species => "cat")
    
    Pet.any_instance.expects(:to_api).with { |arg| arg.fields == [:name, :species] }
    @person.to_api
  end
end

