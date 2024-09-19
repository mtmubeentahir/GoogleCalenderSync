class CreateCalendars < ActiveRecord::Migration[7.1]
  def change
    create_table :calendars do |t|
      t.string :google_id
      t.string :name
      t.string :description
      t.string :time_zone

      t.timestamps
    end
  end
end
