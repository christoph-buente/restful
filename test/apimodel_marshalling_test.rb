require File.dirname(__FILE__) + '/test_helper.rb'

context "apimodel marshalling" do
  
  setup do 
    Person.restful_publish(:name, :current_location, :pets, :sex)
    Pet.restful_publish(:name, :person_id)
    Sex.restful_publish(:sex)
    
    @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
    @pet = @person.pets.create(:species => "cat")
    @sex = @person.sex = Sex.new(:sex => "male")
  end
  
  teardown do
    reset_config
  end
  
  specify "serialize to xml, rails style" do
    actual = @person.to_restful.serialize_to(:xml)
    
    expected = <<EXPECTED
<?xml version="1.0" encoding="UTF-8"?>
<person>
  <restful-url type="link">http://example.com:3000/people/#{ @person.id }</restful-url>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <sex>
    <restful-url type="link">http://example.com:3000/sexes/#{ @sex.id }</restful-url>
    <sex>male</sex>
  </sex>
  <pets type="array">
    <pet>
      <restful-url type="link">http://example.com:3000/pets/#{ @pet.id }</restful-url>
      <person-restful-url type="link">http://example.com:3000/people/#{ @person.id }</person-restful-url>
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
  <link rel="self" href="/people/#{ @person.id }"/>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <sex>
    <link rel="self" href="/sexes/2"/>
    <sex>male</sex>
  </sex>
  <pets>
    <pet>
      <link rel="self" href="/pets/#{ @pet.id }"/>
      <link rel="person_id" href="/people/#{ @person.id }" />
      <name></name>
    </pet>
  </pets>
</person>
EXPECTED

    xml_should_be_same(expected, actual)
  end
  
  specify "deserialize from rails style xml" do
    restful = @person.to_restful
    expected = restful.serialize_to(:xml)
    serializer = Restful::Serializers::XMLSerializer.new
    resource = serializer.deserialize(expected)    
    actual = serializer.serialize(resource)
    
    xml_should_be_same(expected, actual)
  end
  
  specify "serialize to an ar params hash" do
    
    input = <<EXPECTED
<?xml version="1.0" encoding="UTF-8"?>
<pet>
  <person-restful-url type="link">http://example.com:3000/people/#{ @person.id }</person-restful-url>
  <species>123</species>
  <name>Gracie</name>
</pet>
EXPECTED

    params = Restful.from_xml(input).serialize_to(:params)
    clone = Pet.create!(params)
    
    clone.name.should.== "Gracie"
    clone.species.should.== 123
    clone.person_id.should.== @person.id
  end
  
  specify "deserialize from atom style xml" do
    restful = @pet.to_restful
    expected = restful.serialize_to(:atom_like)
    serializer = Restful::Serializers::AtomLikeSerializer.new
    resource = serializer.deserialize(expected)
    actual = serializer.serialize(resource)
    
    xml_should_be_same(expected, actual)
  end
end
