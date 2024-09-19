class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :calendar, null: false, foreign_key: true
      t.string :google_id
      t.string :summary
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :location
      t.string :status

      t.timestamps
    end
  end
end
