FactoryGirl.define do

  factory :issue do

  end

  # trait :with_issue_data do
  #   author    { create(:user) }
  #   tracker   { create(:tracker, name: "some_trackr #{rand(100000)} #{Time.now.to_i}", default_status: create(:issue_status) ) }
  #   priority  { create(:issue_priority) }
  #   status    { tracker.default_status }
  #
  #   before(:create) do |issue, _|
  #     unless issue.project.trackers.include?(issue.tracker )
  #       p = issue.project
  #       p.trackers << issue.tracker
  #       p.save
  #     end
  #   end
  # end
  #
  # factory :tracker do
  #
  # end
  #
  # factory :issue_status do
  #   name "some status #{Time.now.to_i}"
  # end
  #
  # factory :issue_priority do
  #   name "#{Time.now}".last(30)
  # end

end