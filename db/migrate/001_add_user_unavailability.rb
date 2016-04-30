class AddUserUnavailability < ActiveRecord::Migration

  def change
    add_column :users, :unavailable_from, :date
    add_column :users, :unavailable_to, :date
  end


end