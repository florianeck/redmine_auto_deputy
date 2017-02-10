class CreateUserDeputies < ActiveRecord::Migration

  def change
    create_table :user_deputies, :force => true do |t|
      t.integer :user_id
      t.integer :deputy_id
      t.integer :project_id
      t.integer :prio
      t.timestamps
    end
  end


end