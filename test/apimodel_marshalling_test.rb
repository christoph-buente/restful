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
    actual = @person.to_restful.serialize_to(:xml)
    
    expected = <<EXPECTED
<?xml version="1.0" encoding="UTF-8"?>
<person>
  <resource_url type="link">http://example.com:3000/people/#{ @person.id }</resource_url>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <pets type="array">
    <pet>
      <resource_url type="link">http://example.com:3000/pets/#{ @pet.id }</resource_url>
      <name nil="true"></name>
    </pet>
  </pets>
</person>
EXPECTED

    xml_should_be_same(expected, actual)
  end
  
  specify "serialize to xml, atom style" do
    actual = @person.to_restful.serialize_to(:atom_like)
    
    expected = <<EXPECTED    
<?xml version="1.0" encoding="UTF-8"?>
<person xml:base="http://example.com:3000">
  <link rel="self" href="http://example.com:3000/people/#{ @person.id }"/>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <pets>
    <pet>
      <link rel="self" href="http://example.com:3000/pets/#{ @pet.id }"/>
      <name></name>
    </pet>
  </pets>
</person>
EXPECTED
  
    xml_should_be_same(expected, actual)
  end
  
  specify "deserialize from rails style xml" do
    restful = @person.to_restful
    xml = restful.serialize_to(:xml)
    hash = Restful.hash_from_xml(xml)
    # puts hash.inspect
  end
  
  specify "deserialize from atom style xml" do
    restful = @person.to_restful
    xml = restful.serialize_to(:atom_like)
    hash = Restful.hash_from_atom_like(xml)  
  end
  
end