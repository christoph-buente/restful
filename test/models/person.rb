class Person < ActiveRecord::Base
  has_many :pets
  has_one  :sex
  
  apiable
end
