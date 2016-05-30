require 'spec_helper'
RSpec.describe RedmineAutoDeputy::UserDeputyExtension do

  describe 'has_many :user_deputies' do
    let(:user) { build(:user, id: 1) }
    specify { expect(user.user_deputies.to_sql).to eq("SELECT `user_deputies`.* FROM `user_deputies` WHERE `user_deputies`.`user_id` = 1  ORDER BY `user_deputies`.`project_id` DESC, `user_deputies`.`prio` ASC") }
  end

  describe 'scope :with_deputy_permission' do
    before { expect(described_class).to receive(:roles_for).with(:edit_deputies).and_return([double(id: 1), double(id: 2)]) }
    specify { expect(User.with_deputy_permission(:edit_deputies).to_sql).to eq("SELECT `users`.* FROM `users` INNER JOIN `members` ON `members`.`user_id` = `users`.`id` INNER JOIN `member_roles` ON `member_roles`.`member_id` = `members`.`id` INNER JOIN `roles` ON `roles`.`id` = `member_roles`.`role_id` WHERE `users`.`type` IN ('User', 'AnonymousUser') AND `member_roles`.`role_id` IN (1, 2) GROUP BY `users`.`id`")}
  end


  specify '.roles_for' do
    expect(described_class.roles_for(:edit_deputies).to_sql).to eq("SELECT `roles`.* FROM `roles` WHERE (`roles`.`permissions` LIKE '%edit_deputies%')")
  end

  describe '#find_deputy' do

    let(:user) { create(:user) }
    let(:deputy) { create(:user, firstname: 'dep')}

    context 'no deputy found' do
      specify { expect(user.find_deputy).to be(nil) }
    end

    context 'deputy found and available' do
      let!(:user_deputy) { create(:user_deputy, user: user, deputy: deputy) }

      specify do
        expect(user.find_deputy).to eq(user_deputy)
      end
    end

    context 'deputy found among multiple projects' do
      let!(:user_deputy_wo_project) { create(:user_deputy, user: user, deputy: deputy, prio: 2) }
      let!(:user_deputy_project_1) { create(:user_deputy, user: user, deputy: deputy, prio: 1, project_id: 1) }
      let!(:user_deputy_project_2) { create(:user_deputy, user: user, deputy: deputy, prio: 1, project_id: 2) }

      specify do
        expect(user.find_deputy(project_id: 1)).to eq(user_deputy_project_1)
      end
    end

    context 'find in multi levels' do
      let(:second_dep) { create(:user, firstname: 'sec', unavailable_from: Time.now+2.days, unavailable_to: Time.now+5.days) }

      let!(:user_deputy) { create(:user_deputy, user: user, deputy: second_dep) }
      let!(:sec_user_deputy) { create(:user_deputy, user: second_dep, deputy: third_dep) }


      context 'steps to next user when first level is not available' do
        let(:third_dep) { create(:user, firstname: 'third') }
        specify { expect(user.find_deputy(date: Time.now+3.days)).to eq(sec_user_deputy) }
      end

      context 'avoids inifinite loops' do
        let!(:third_dep) { create(:user, firstname: 'third', unavailable_from: Time.now+2.days, unavailable_to: Time.now+5.days) }
        let!(:third_user_deputy) { create(:user_deputy, user: third_dep, deputy: user) }

        specify { expect(user.find_deputy(date: Time.now+3.days)).to eq(nil) }
      end

    end

  end

end