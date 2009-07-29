class Sex < ActiveRecord::Base
  belongs_to :person
  
  apiable
end
