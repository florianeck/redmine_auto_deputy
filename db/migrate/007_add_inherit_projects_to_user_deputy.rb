class AddInheritProjectsToUserDeputy < ActiveRecord::Migration

  def change
    add_column :user_deputies, :projects_inherit, :boolean, :default => true
  end

end