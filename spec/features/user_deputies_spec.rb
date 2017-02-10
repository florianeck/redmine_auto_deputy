require "spec_helper"
RSpec.describe "User Deputies", type: :feature do

  let(:admin) { create(:user, admin: true) }

  before do
    allow(User).to receive(:current).and_return(admin)
    # just allow everything to the user
    allow(admin).to receive(:allowed_to_globally?).and_return(true)
  end

  describe 'renders #index with all required elements' do
    specify do
      visit user_deputies_path

      # User Dropdown Menu
      expect(find("select#user_id")[:onchange]).to eq("window.location='#{user_deputies_path}?user_id='+this.value")

      # Availablility Form
      page.find('input#user_availability_unavailable_from')
      page.find('input#user_availability_unavailable_to')
      page.find('input#user_availability_delete_availabilities[type=checkbox]')
      expect(page.body).to include(I18n.t('user_deputies.index.form.submit_availability'))

      # New Deputy Form
      page.find('form#new_user_deputy')
      page.find('select#user_deputy_deputy_id')
      page.find('#deputy-project-select')
      expect(page.body).to include(I18n.t('user_deputies.index.form.select_deputy'))
      expect(page.body).to include(I18n.t('user_deputies.index.form.submit_deputy'))
    end
  end

end