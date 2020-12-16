class RenameHashFromCurrency < ActiveRecord::Migration[6.0]
  def change
    rename_column :currencies, :hash, :hash_digest
  end
end
