class Pet < ActiveRecord::Base
  belongs_to :owner, :class_name => "Person", :foreign_key => "person_id"  

  apiable
end
