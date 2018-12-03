require "spec_helper"
RSpec.describe UserDeputy do

  let(:user_deputy) { create(:user_deputy, user_id: rand(10000), deputy_id: rand(10000)) }

  specify { expect(described_class.all.to_sql).to eq("SELECT user_deputies.* FROM user_deputies  ORDER BY user_deputies.project_id DESC, user_deputies.prio ASC")}

  describe 'scopes' do
    specify ':with_projects' do
      expect(described_class.with_projects.to_sql).to eq("SELECT user_deputies.* FROM user_deputies INNER JOIN projects ON projects.id = user_deputies.project_id WHERE (user_deputies.project_id IS NOT NULL)  ORDER BY projects.name ASC, user_deputies.prio ASC")
    end

    specify ':without_projects' do
      expect(described_class.without_projects.to_sql).to eq("SELECT user_deputies.* FROM user_deputies WHERE user_deputies.project_id IS NULL  ORDER BY user_deputies.prio ASC")
    end

  end

  specify { expect(described_class.included_modules).to include(ActiveRecord::Acts::List::InstanceMethods)}


  context "enable/disable" do
    before { allow(Time).to receive(:now).and_return(DateTime.new(2016,1,1,1,1)) }

    describe '#enable!' do
      before { expect(user_deputy).to receive(:update_attributes).with(disabled: false, disabled_at: nil).and_call_original }
      specify { expect(user_deputy.enable!).to be(true) }
    end

    describe '#disable!' do
      before { expect(user_deputy).to receive(:update_attributes).with(disabled: true, disabled_at: Time.now).and_call_original }
      specify { expect(user_deputy.disable!).to be(true) }
    end
  end

end