class CreateSurvey < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.column :name, :string

      t.timestamps
    end
    create_table :questions do |t|
      t.column :desc, :string
      t.column :survey_id, :int

      t.timestamps
    end
    create_table :answers do |t|
      t.column :desc, :string
      t.column :question_id, :int
    end
  end
end
