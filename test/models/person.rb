class Person < ActiveRecord::Base
  has_many :pets
  belongs_to  :sex
  belongs_to  :haircut

  accepts_nested_attributes_for :pets
  accepts_nested_attributes_for :sex
  
  apiable
end
