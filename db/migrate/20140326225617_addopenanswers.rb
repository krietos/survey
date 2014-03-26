class Addopenanswers < ActiveRecord::Migration
  def change
    add_column :answers, :open_answer, :string
  end
end
