class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usages do |t|
      t.string :kind
      t.date :date
      t.integer :usage
      t.integer :cost_cents

      t.timestamps
    end
  end
end
