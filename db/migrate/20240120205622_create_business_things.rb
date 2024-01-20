# frozen_string_literal: true

class CreateBusinessThings < ActiveRecord::Migration[7.1]
  def change
    create_table :business_things do |t|
      t.decimal :amount
      t.timestamps
    end
  end
end
