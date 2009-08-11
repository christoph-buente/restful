require File.dirname(__FILE__) + '/../test_helper.rb'

context "params serializer" do
  setup do 
    Person.restful_publish(:name, :current_location, :pets, :wallet)
    Pet.restful_publish(:name)
    Wallet.restful_publish(:contents)
  
    @person = Person.create(:name => "Joe Bloggs", :current_location => "Under a tree")
    @pet = @person.pets.create(:species => "cat", :age => 200, :name => "mietze")
    @wallet = @person.wallet = Wallet.new(:contents => "an old photo, 5 euros in coins")
    @person.save
  end

  teardown do
    reset_config
  end

  specify "deserialize from rails style xml" do
    restful = @person.to_restful
    expected = restful.serialize(:xml)
    serializer = Restful::Serializers::XMLSerializer.new
    resource = serializer.deserialize(expected)    
    actual = serializer.serialize(resource)

    xml_should_be_same(expected, actual)
  end
  
  specify "serialize to xml, rails style" do
    actual = @person.to_restful.serialize(:xml)

    expected = <<EXPECTED
<?xml version="1.0" encoding="UTF-8"?>
<person>
  <restful-url type="link">http://example.com:3000/people/#{ @person.id }</restful-url>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <pets type="array">
    <pet>
      <restful-url type="link">http://example.com:3000/pets/#{ @pet.id }</restful-url>
      <name>mietze</name>
    </pet>
  </pets>
  <wallet>
    <restful-url type="link">http://example.com:3000/wallets/#{ @wallet.id }</restful-url>
    <contents>an old photo, 5 euros in coins</contents>
  </wallet>
</person>
EXPECTED
    xml_should_be_same(expected, actual)
  end

end
