class Addcolumn < ActiveRecord::Migration
  def change
    add_column :answers, :times_chosen, :int
  end
end
