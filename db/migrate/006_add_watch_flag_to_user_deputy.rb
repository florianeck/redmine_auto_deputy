class AddWatchFlagToUserDeputy < ActiveRecord::Migration

  def change
    add_column :user_deputies, :auto_watch_project_issues, :boolean, :default => true
  end

end