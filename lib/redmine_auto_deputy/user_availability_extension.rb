module RedmineAutoDeputy::UserAvailabilityExtension
  extend ActiveSupport::Concern

  included do
    before_save :validate_unavailabilities
  end


  def unavailablity_set?
    unavailable_from.present? && unavailable_to.present? && unavailable_to > Time.now
  end

  def available_at?(date = Time.now.to_date)
    if unavailablity_set?
      !(unavailable_from..unavailable_to).to_a.include?(date.to_date)
    else
      return true
    end
  end


  private

  def validate_unavailabilities
    self.errors.add(:unavailable_from, I18n.t('activerecord.errors.user.missing_unavailable_from')) if unavailable_from.nil? && unavailable_to.present?
    self.errors.add(:unavailable_to, I18n.t('activerecord.errors.user.missing_unavailable_to')) if unavailable_to.nil? && unavailable_from.present?

    if unavailable_from.present? && unavailable_to.present? && (unavailable_from < Time.now.to_date || unavailable_to < Time.now.to_date)
      self.errors.add(:unavailable_to, I18n.t('activerecord.errors.user.unavailable_dates_in_past'))
    end

    if unavailable_from.present? && unavailable_to.present? && (unavailable_to < unavailable_from)
      self.errors.add(:unavailable_to, I18n.t('activerecord.errors.user.unavailable_to_before_from'))
    end

    return self.errors.empty?
  end

end