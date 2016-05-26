require "spec_helper"
RSpec.describe UserDeputy do

  specify { expect(described_class.all.to_sql).to eq("SELECT `user_deputies`.* FROM `user_deputies`  ORDER BY `user_deputies`.`project_id` DESC, `user_deputies`.`prio` ASC")}

  describe 'scopes' do
    specify ':with_projects' do
      expect(described_class.with_projects.to_sql).to eq("SELECT `user_deputies`.* FROM `user_deputies` INNER JOIN `projects` ON `projects`.`id` = `user_deputies`.`project_id` WHERE (`user_deputies`.`project_id` IS NOT NULL)  ORDER BY projects.name ASC, `user_deputies`.`prio` ASC")
    end

    specify ':without_projects' do
      expect(described_class.without_projects.to_sql).to eq("SELECT `user_deputies`.* FROM `user_deputies` WHERE `user_deputies`.`project_id` IS NULL  ORDER BY `user_deputies`.`prio` ASC")
    end

  end

  specify { expect(described_class.included_modules).to include(ActiveRecord::Acts::List::InstanceMethods)}

end