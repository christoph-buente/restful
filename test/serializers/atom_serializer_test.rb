require File.dirname(__FILE__) + '/../test_helper.rb'

context "params serializer" do

  setup do 
    Person.restful_publish(:name, :current_location, :pets, :wallet, :created_at)
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

  specify "serialize to xml, atom style" do
    actual = @person.to_restful.serialize(:atom_like)

    expected = <<EXPECTED    
<?xml version="1.0" encoding="UTF-8"?>
<person xml:base="http://example.com:3000">
  <created-at>#{ @person.created_at.xmlschema }</created-at>
  <link rel="self" href="/people/#{ @person.id }"/>
  <name>Joe Bloggs</name>
  <current-location>Under a tree</current-location>
  <pets>
    <pet>
      <link rel="self" href="/pets/#{ @pet.id }"/>
      <name>mietze</name>
    </pet>
  </pets>
  <wallet>
    <link rel="self" href="/wallets/#{ @wallet.id }"/>
    <contents>an old photo, 5 euros in coins</contents>
  </wallet>
</person>
EXPECTED

    xml_should_be_same(expected, actual)
  end


specify "deserialize from atom style xml" do
  restful = @pet.to_restful
  expected = restful.serialize(:atom_like)
  serializer = Restful::Serializers::AtomLikeSerializer.new
  resource = serializer.deserialize(expected)
  actual = serializer.serialize(resource)
  
  xml_should_be_same(expected, actual)
end

end