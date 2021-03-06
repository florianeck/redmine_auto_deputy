require "spec_helper"
require "timecop"
RSpec.describe RedmineAutoDeputy::UserAvailabilityExtension do

  specify { expect(User.included_modules).to include(described_class)}

  describe 'validate_unavailabilities on before_save' do
    let(:filter) { User._save_callbacks.select {|c| c.kind ==  :before && c.filter == :validate_unavailabilities }.first }
    specify { expect(filter).not_to be(nil) }
  end

  describe '#unavailablity_set?' do
    context 'nothing set' do
      let(:user) { build_stubbed(:user) }
      specify { expect(user.unavailablity_set?).to be(false) }
    end

    context 'values set' do
      let(:user) { build_stubbed(:user, unavailable_from: Time.now+1.day, unavailable_to: Time.now+2.days) }
      specify { expect(user.unavailablity_set?).to be(true) }
    end

    context 'values in past' do
      let(:user) { build_stubbed(:user, unavailable_from: Time.now-10.day, unavailable_to: Time.now-2.days) }
      specify { expect(user.unavailablity_set?).to be(false) }
    end
  end

  describe '#available_at?'do
    context 'with unavailablilty set' do
      let(:user) { build_stubbed(:user, unavailable_from: (Time.now+1.day).to_date, unavailable_to: (Time.now+4.days).to_date) }

      specify { expect(user.available_at?).to be(true) }
      specify { expect(user.available_at?(Time.now+1.day)).to be(false) }
      specify { expect(user.available_at?(Time.now+3.days)).to be(false) }
      specify { expect(user.available_at?(Time.now+4.days)).to be(false) }
      specify { expect(user.available_at?(Time.now+5.days)).to be(true) }
    end

    context 'without unavailablilty set' do
      let(:user) { build_stubbed(:user) }
      specify { expect(user.available_at?(Time.now)).to be(true)}
    end

    context 'only one day unavailable' do
      let(:user) { build_stubbed(:user, unavailable_from: (Time.now+1.day).to_date, unavailable_to: (Time.now+1.day).to_date) }
      specify { expect(user.available_at?(Time.now+1.day)).to be(false)}
    end

    context 'only today unavailable' do
      let(:user) { build_stubbed(:user, unavailable_from: (Time.now).to_date, unavailable_to: (Time.now).to_date) }
      specify { expect(user.available_at?(Time.now)).to be(false)}
    end

  end

  describe '#validate_unavailabilities' do
    context 'unavailable_to set/unavailable_from not set' do
      let(:user) { build_stubbed(:user, unavailable_to: Time.now+1.day)}
      specify do
        expect(user.send(:validate_unavailabilities)).to be(false)
        expect(user.errors[:unavailable_from]).to eq([I18n.t('activerecord.errors.user.missing_unavailable_from')])
      end
    end

    context 'unavailable_from set/unavailable_to not set' do
      let(:user) { build_stubbed(:user, unavailable_from: Time.now+1.day)}
      specify do
        expect(user.send(:validate_unavailabilities)).to be(false)
        expect(user.errors[:unavailable_to]).to eq([I18n.t('activerecord.errors.user.missing_unavailable_to')])
      end
    end

    context 'unavailable_from in the past' do
      let(:user) { create(:user)}

      specify do
        expect(user.update_attributes(unavailable_from: Time.now-2.day, unavailable_to: Time.now+1.day)).to be(false)
        expect(user.errors[:unavailable_to]).to eq([I18n.t('activerecord.errors.user.unavailable_dates_in_past')])
      end
    end

    context 'unavailable_to < unavailable_from' do
      let(:user) { build_stubbed(:user, unavailable_from: Time.now+2.day, unavailable_to: Time.now+1.day)}
      specify do
        expect(user.send(:validate_unavailabilities)).to be(false)
        expect(user.errors[:unavailable_to]).to eq([I18n.t('activerecord.errors.user.unavailable_to_before_from')])
      end
    end

    context 'only one day unavailable' do
      let(:user) { build_stubbed(:user, unavailable_from: (Time.now).to_date, unavailable_to: (Time.now).to_date) }

      specify do
        expect(user.send(:validate_unavailabilities)).to be(true)
      end
    end
  end

  describe '#clear_expired_unavailability!' do

    context 'add new availablitly in the past' do
      let(:user) { create(:user) }

      specify 'fails on validation' do
        expect(user.update_attributes(unavailable_from: Time.now-1.day, unavailable_to: Time.now+1.day)).to be(false)
        expect(user.errors[:unavailable_to]).to be_present
      end
    end

    context 'user has expired_unavailability' do
      let(:user) { create(:user, unavailable_from: Time.now, unavailable_to: Time.now+3.days) }

      before { Timecop.travel(Time.now+10.days) }

      specify do
        expect(user.update_attributes(login: 'newlogin')).to be(true)
        expect(user.reload.unavailable_from).to be(nil)
        expect(user.reload.unavailable_to).to be(nil)
      end

      after { Timecop.return }
    end

  end

end
