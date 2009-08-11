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
  
  specify "serialize to params" do
    actual = @person.to_restful.serialize(:params)
  
    expected = 
      {
        :name => "Joe Bloggs",
        :current_location => "Under a tree",
        :created_at => @person.created_at,
        :wallet_attributes=>{:contents=>"an old photo, 5 euros in coins"},
        :pets_attributes => [ {:name => "mietze"} ]
      }

    actual.should.== expected
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

    params = Restful.from_xml(input).serialize(:params)
    clone = Pet.create!(params)

    clone.name.should.== "Gracie"
    clone.species.should.== 123
    clone.person_id.should.== @person.id
  end
  
  specify "deserialize from params" do
    restful = @person.to_restful
    expected = restful.serialize(:params)
    serializer = Restful::Serializers::ParamsSerializer.new
    resource = serializer.deserialize(expected)
    actual = Person.create(expected).to_restful.serialize(:params)
  
    actual.should.== expected
  end
end