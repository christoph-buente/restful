class Wallet < ActiveRecord::Base
  belongs_to :person  

  apiable
end