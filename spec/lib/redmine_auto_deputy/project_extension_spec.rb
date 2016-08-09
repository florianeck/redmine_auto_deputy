require 'spec_helper'

RSpec.describe RedmineAutoDeputy::ProjectExtension do

  before(:each) do
    Tracker.delete_all
    IssueStatus.delete_all
    IssuePriority.delete_all
  end

  specify { expect(Project.included_modules).to include(described_class)}

  let(:user) { create(:user) }

  describe '#possible_project_id_for_deputies' do
    let(:project) { create(:project, identifier: "mytest#{rand(5000)}") }

    context 'no deputy data available' do
      specify { expect(project.possible_project_id_for_deputies(user)).to be_nil }
    end

    context 'has its own deputy setting' do
      let!(:user_deputy) { create(:user_deputy, user_id: user.id, project_id: project.id, projects_inherit: false) }
      specify { expect(project.possible_project_id_for_deputies(user)).to eq(project.id) }
    end

    context 'parent has deputy setting' do
      let(:project_sub1) { create(:project, identifier: "mytest-sub1#{rand(5000)}", parent: project) }
      let(:project_sub2) { create(:project, identifier: "mytest-sub2#{rand(5000)}", parent: project_sub1) }

      context 'allow inheritance' do
        let!(:user_deputy) { create(:user_deputy, user_id: user.id, project_id: project.id, projects_inherit: true) }
        specify { expect(project_sub2.possible_project_id_for_deputies(user)).to eq(project.id)}
      end

      context 'dont allow inheritance' do
        let!(:user_deputy) { create(:user_deputy, user_id: user.id, project_id: project.id, projects_inherit: false) }
        specify { expect(project_sub2.possible_project_id_for_deputies(user)).to be_nil }
      end

    end
  end

end