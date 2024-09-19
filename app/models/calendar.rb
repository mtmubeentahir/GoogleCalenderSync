class Calendar < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :google_id, presence: true, uniqueness: true
end
