module RedmineAutoDeputy::UserAvailabilityExtension
  extend ActiveSupport::Concern

  included do
    before_save :validate_unavailabilities
  end


  def unavailablity_set?
    unavailable_from.present? && unavailable_to.present? && unavailable_to >= Time.now.to_date
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
    clear_expired_unavailability!

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

  def clear_expired_unavailability!
    if !self.changed_attributes.keys.include?('unavailable_from') && !self.changed_attributes.keys.include?('unavailable_to') && self.persisted?
      if self[:unavailable_from].present? && self[:unavailable_from] < Time.now || self[:unavailable_to].present? && self[:unavailable_to] < Time.now
        self[:unavailable_from] = nil
        self[:unavailable_to]   = nil
      end
    end
  end

end