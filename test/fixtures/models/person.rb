class Person < ActiveRecord::Base
  has_many :pets
  has_one  :wallet

  accepts_nested_attributes_for :pets
  accepts_nested_attributes_for :wallet
  
  def oldest_pet
    pets.first :order => "age DESC"
  end
  
  def location_sentence
    "Hi. I'm currently in #{ current_location }"
  end
  
  apiable
end
