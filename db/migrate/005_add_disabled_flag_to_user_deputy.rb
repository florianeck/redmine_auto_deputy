class AddDisabledFlagToUserDeputy < ActiveRecord::Migration

  def change
    add_column :user_deputies, :disabled, :boolean, :default => false
    add_column :user_deputies, :disabled_at, :datetime
  end

end