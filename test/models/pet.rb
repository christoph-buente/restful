class Pet < ActiveRecord::Base
  belongs_to :person
  apiable
end