require "spec_helper"
RSpec.describe "User Deputies", type: :feature do

  let(:admin) { create(:user, admin: true) }

  before do
    allow(User).to receive(:current).and_return(admin)
    allow(admin).to receive(:allowed_to_globally?).and_return(true)
  end

  describe 'renders #index with all required elements' do
    specify do
      # TODO
    end
  end

end