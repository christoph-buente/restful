# Why?

Aims to provide a production quality Rest API to your Rails app, with the following features:

  * whitelisting
  * flexible xml formats with good defaults
  * all resources are referred to by url and not by id; expose a "web of resources"
  
# Serializers

Rails-like
==========

This format sticks to xml_simple, adding links as `<association-name-restful-url>` nodes of type "link".

`Person.last.to_restful.serialize_to(:xml)` results in something like...

    <?xml version="1.0" encoding="UTF-8"?>
    <person>
      <restful_url type="link">http://example.com:3000/people/1</restful_url>
      <name>Joe Bloggs</name>
      <current-location>Under a tree</current-location>
      <pets type="array">
        <pet>
          <restful-url type="link">http://example.com:3000/pets/2</restful-url>
          <person-restful-url type="link">http://example.com:3000/people/1</person-restful-url>
          <name nil="true"></name>
        </pet>
      </pets>
    </person>
    

Atom-like
=========

`Person.last.to_restful.serialize_to(:atom_like)` results in something like...

  <?xml version="1.0" encoding="UTF-8"?>
  <person xml:base="http://example.com:3000">
    <link rel="self" href="/people/1" />
    <name>Joe Bloggs</name>
    <current-location>Under a tree</current-location>
    <pets>
      <pet>
        <link rel="self" href="/pets/2" />
        <link rel="person" href="/people/1" />
        <name></name>
      </pet>
    </pets>
  </person>
  
Deserializing
=============

Use `Restful.from_atom_like(xml).serialize_to(:hash)` to convert from an atom-like formatted xml create to a params hash. Takes care of dereferencing the urls back to ids. Generally, use `Restful.from_<serializer name>(xml)` to get a Resource.