require 'spec_helper'

RSpec.describe RedmineAutoDeputy::IssueExtension do

  specify { expect(Issue.included_modules).to include(described_class)}

  describe 'check_assigned_user_availability on before_save if assigned_to_id_changed?' do
    let(:filter) { Issue._save_callbacks.select {|c| c.kind ==  :before && c.filter == :check_assigned_user_availability }.first }
    specify do
      expect(filter.instance_variable_get('@if')).to match_array([:assigned_to_id_changed?])
    end
  end

  describe '#check_assigned_user_availability' do

    context 'assigned_to.nil?' do
      let(:issue) { build_stubbed(:issue) }
      specify do
        expect(issue.send(:check_assigned_user_availability)).to be(nil)
        expect(issue.assigned_to).to be(nil)
      end
    end

    context 'uses current date if no due_to date is assigned' do
      let(:issue) { build_stubbed(:issue, assigned_to: user) }
      let(:user)  { build_stubbed(:user)}

      before { expect(user).to receive(:available_at?).with(Time.now.to_date).and_return true }
      specify { expect(issue.send(:check_assigned_user_availability)).to be(true) }
    end

    context 'uses due_to date to find deputy' do
      let(:date)    { Time.now.to_date+1.week }
      let(:issue)   { build_stubbed(:issue, assigned_to: user, due_date: date, project_id: 1) }
      let(:user)    { build_stubbed(:user)}
      let(:deputy)  { build_stubbed(:user)}

      before do
        expect(user).to receive(:available_at?).with(date).and_return false
        expect(user).to receive(:find_deputy).with(project_id: 1, date: date).and_return(deputy)
      end

      specify do
        expect(issue.send(:check_assigned_user_availability)).to eq(true)
        expect(issue.assigned_to).to eq(deputy)
      end
    end

    context 'fails to find deputy' do
      let(:date)    { Time.now.to_date+1.week }
      let(:issue) { build_stubbed(:issue, assigned_to: user, project_id: 1, due_date: date) }
      let(:user)  { build_stubbed(:user)}

      before do
        expect(user).to receive(:available_at?).with(date).and_return false
        expect(user).to receive(:find_deputy).with(project_id: 1, date: date).and_return(nil)
      end

      specify do
        expect(issue.send(:check_assigned_user_availability)).to eq(false)
        expect(issue.errors[:assigned_to]).not_to be_empty
      end

    end

  end

end