require File.dirname(__FILE__) + '/test_helper.rb'

context "apimodel marshalling" do
  
  setup do 
    Person.restful_publish(:name, :current_location, :pets)
    Pet.restful_publish(:name)
    
    @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
    @pet = @person.pets.create(:species => "cat")
  end
  
  teardown do
    reset_config
  end
  
  specify "serialize to xml, rails style" do
    xml = @person.to_api.serialize_to(:xml)
    
    expected = <<EXPECTED
<?xml version="1.0" encoding="UTF-8"?>
<person>
  <resource_url type="link">/people/#{ @person.id }</resource_url>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <pets type="array">
    <pet>
      <resource_url type="link">/pets/#{ @pet.id }</resource_url>
      <name nil="true"></name>
    </pet>
  </pets>
</person>
EXPECTED

    xml.should.equal expected  
  end
  
  specify "serialize to xml, atom style" do
    xml = @person.to_api.serialize_to(:atom_pub)
    
    expected = <<EXPECTED
<?xml version="1.0" encoding="UTF-8"?>
<person>
  <link href="/people/#{ @person.id }" rel="self"/>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <pets type="array">
    <pet>
      <link href="/pets/#{ @pet.id }" rel="self"/>
      <name nil="true"></name>
    </pet>
  </pets>
</person>
EXPECTED
  
    xml.should.equal expected   
  end

  # specify "deserialize from rails style xml" do
  #   flunk     
  # end
  
  # specify "deserialize from atom style xml" do
  #   flunk     
  # end
  
end