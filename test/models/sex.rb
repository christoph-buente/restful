class Sex < ActiveRecord::Base
  has_many :person
  
  apiable

  def foo
    "bar"
  end

  def first_person
    Person.first
  end
end
