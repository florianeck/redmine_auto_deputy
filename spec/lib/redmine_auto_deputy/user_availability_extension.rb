module RedmineAutoDeputy::UserAvailabilityExtension
  extend ActiveSupport::Concern

  included do
    before_save :validate_unavailabilities
  end


  def unavailablity_set?
    unavailable_from.present? && unavailable_to.present?
  end

  def available_at?(date = Time.now.to_date)
    if unavailablity_set?
      !(unavailable_from..unavailable_to).to_a.include?(date)
    else
      return true
    end
  end


  private

  def validate_unavailabilities

  end

end