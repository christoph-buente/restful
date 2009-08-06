# Disclaimer

!!! Refactor this shice. Seriously, this has devolved into some nasty-ass code. 

# Why?

Aims to provide a production quality Rest API to your Rails app, with the following features:

  * whitelisting
  * flexible xml formats with good defaults
  * all resources are referred to by url and not by id; expose a "web of resources"
  
# Serializers

Getting started
===============
In order to make your models apiable add

`apiable`

to your model. Next, define which properties you want to export, so within the model write something like:

`self.restful_publish(:name, :current-location, :pets)`

Configuration
=============

Some example configurations:

# Person
restful_publish :name, :pets, :restful_options => { :expansion => :expanded } # default on level 1-2: expanded. default above: collapsed. 
restful_publish :name, :pets, :wallet => :contents, :restful_options => { :expansion => :expanded } # combined options and expansion rules
restful_publish :name, :pets, :restful_options => { :collapsed => :pets } # collapsed pets, even though they are on the second level. 
restful_publish :name, :pets, :restful_options => { :expanded => [:pets, :wallet] }
restful_publish :name, :pets, :restful_options => { :pets_page => 1, :pets_per_page => 100, :collapsed => :pets }

# Pet
restful_publish :name, :person # expands person per default because it is on the second level. Does not expand person.pets.first.person, since this is higher than second level.

Rails-like
==========

This format sticks to xml_simple, adding links as `<association-name-restful-url>` nodes of type "link".

`Person.last.to_restful.serialize(:xml)` results in something like...

  <?xml version="1.0" encoding="UTF-8"?>
  <person>
    <restful-url type="link">http://example.com:3000/people/1</restful-url>
    <name>Joe Bloggs</name>
    <current-location>Under a tree</current-location>
    <pets type="array">
      <pet>
        <restful-url type="link">http://example.com:3000/pets/1</restful-url>
        <person-restful-url type="link">http://example.com:3000/people/1</person-restful-url>
        <name nil="true"></name>
      </pet>
    </pets>
    <sex>
      <restful-url type="link">http://example.com:3000/sexes/1</restful-url>
      <sex>male</sex>
    </sex>
  </person>
  

Atom-like
=========

`Person.last.to_restful.serialize(:atom_like)` results in something like...

  <?xml version="1.0" encoding="UTF-8"?>
  <person xml:base="http://example.com:3000">
    <link rel="self" href="/people/1"/>
    <name>Joe Bloggs</name>
    <current-location>Under a tree</current-location>
    <pets>
      <pet>
        <link rel="self" href="/pets/1"/>
        <link rel="person_id" href="/people/1"/>
        <name></name>
      </pet>
    </pets>
    <sex>
      <link rel="self" href="/sexes/1"/>
      <sex>male</sex>
    </sex>
  </person>
  
Params-like
===========

`Person.last.to_restful.serialize(:params)` results in something like...

  {:sex_attributes => {:sex=>"male"},
   :current_location=>"Under a tree",
   :name=>"Joe Bloggs",
   :pets_attributes=> [ {:person_id=>1, :name=>nil} ] 
  }

Deserializing
=============

Use `Restful.from_atom_like(xml).serialize(:hash)` to convert from an atom-like formatted xml create to a params hash. Takes care of dereferencing the urls back to ids. Generally, use `Restful.from_<serializer name>(xml)` to get a Resource.

Nested Attributes
=================
Serializing uses Rails 2.3 notation of nested attributes. For deserializing you will need Rails 2.3 for having nested attributes support and the respective model must have the 
`accepts_nested_attributes_for :<table name>` set accordingly
