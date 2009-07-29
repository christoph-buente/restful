class Person < ActiveRecord::Base
  has_many :pets
  has_one  :sex

  accepts_nested_attributes_for :pets
  accepts_nested_attributes_for :sex
  
  apiable
end
