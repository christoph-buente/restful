require File.dirname(__FILE__) + '/test_helper.rb'

context "apimodel marshalling" do
  
  setup do 
    Person.restful_publish(:name, :current_location, :pets, :sex)
    Pet.restful_publish(:name)
    Sex.restful_publish(:sex)
    
    @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
    @pet = @person.pets.create(:species => "cat")
    @sex = @person.sex = Sex.new(:sex => "male")
    @haircut = @person.haircut = Haircut.new(:style => "fieser Scheitel")

  end
  
  teardown do
    reset_config
  end

  specify "should be able to handle relations that are nil/null" do
    @person.sex = nil
    @person.save!
    @person.reload

    assert_nothing_raised do
      @person.to_restful
    end

  end

  specify "should throw senseful exception if a relation is no apiable" do 
    @person.to_restful(:haircut)
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
    <link rel="self" href="/sexes/#{ @sex.id }"/>
    <sex>male</sex>
  </sex>
  <pets>
    <pet>
      <link rel="self" href="/pets/#{ @pet.id }"/>
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

  specify "serialize to params" do
    actual = @person.to_restful.serialize_to(:params)
    
    expected = 
      {
        :name => "Joe Bloggs",
        :current_location => "Under a tree",
        :sex_attributes => {
          :sex => "male"
        },
        :pets_attributes => [ {:name => nil} ]
      }

    actual.should.== expected
  end

  specify "deserialize from params" do
    restful = @person.to_restful
    expected = restful.serialize_to(:params)
    serializer = Restful::Serializers::ParamsSerializer.new
    resource = serializer.deserialize(expected)
    actual = Person.create(expected).to_restful.serialize_to(:params)
    
    actual.should.== expected
  end
end
