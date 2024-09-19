class Event < ApplicationRecord
  belongs_to :calendar

  validates :google_id, presence: true, uniqueness: true
end
