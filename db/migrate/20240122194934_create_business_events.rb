class CreateBusinessEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :business_events do |t|
      t.references :business_thing, null: false, foreign_key: true
      t.string :action
      t.uuid :group_id
      t.timestamps
    end

    add_index :business_events, :group_id
  end
end
