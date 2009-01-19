class Person < ActiveRecord::Base
  has_many :pets
  apiable
end