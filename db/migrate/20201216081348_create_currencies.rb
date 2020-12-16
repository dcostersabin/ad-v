class CreateCurrencies < ActiveRecord::Migration[6.0]
  def change
    create_table :currencies do |t|
      t.text :hash
      t.boolean :validity

      t.timestamps
    end
  end
end
