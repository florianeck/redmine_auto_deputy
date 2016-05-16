require "spec_helper"
RSpec.describe UserDeputy do

  specify { expect(described_class.all).to eq("SELECT `user_deputies`.* FROM `user_deputies`  ORDER BY `user_deputies`.`prio` ASC, `user_deputies`.`project_id` ASC")}
  specify { expect(described_class.included_modules).to include(ActiveRecord::Acts::List::InstanceMethods)}

end