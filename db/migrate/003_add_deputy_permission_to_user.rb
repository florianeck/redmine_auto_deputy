class AddDeputyPermissionToUser < ActiveRecord::Migration

  def change
    add_column :users, :can_have_deputies, :boolean, default: true
    add_column :users, :can_be_deputy,     :boolean, default: true
  end

end