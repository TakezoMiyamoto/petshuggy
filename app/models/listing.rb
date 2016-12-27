class Listing < ActiveRecord::Base
  belongs_to :user

  #必須項目
  validates :home_type, precence: true
  validates :pet_type, precence: true
  validates :pet_size, precence: true
  validates :breeding_years, precence: true

end
