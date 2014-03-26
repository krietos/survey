class Addother < ActiveRecord::Migration
  def change
    add_column :questions, :allow_other, :boolean
  end
end
