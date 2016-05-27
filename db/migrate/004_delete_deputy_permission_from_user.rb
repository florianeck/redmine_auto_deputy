class DeleteDeputyPermissionFromUser < ActiveRecord::Migration

  # This migration cleans up a mistake made in the recent release
  # THe previous/wrong migration 003 has been deleted
  def change
    remove_column :users, :can_have_deputies if User.column_names.include?('can_have_deputies')
    remove_column :users, :can_be_deputy if User.column_names.include?('can_be_deputy')
  end

end