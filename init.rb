require 'redmine'

Redmine::Plugin.register :chiliproject_travel_report do
  name 'Travel Report'
  author 'Eric Davis'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author_url 'http://www.littlestreamsoftware.com'
  description 'Shows travel requests'
  version '0.1.0'

  settings(:partial => 'settings/travel_report',
           :default => {
             'depart_custom_field_id' => nil,
             'return_custom_field_id' => nil,
             'approved_issue_status_ids' => [],
             'denied_issue_status_ids' => []
           })

  permission(:travel_reports, {:travel_reports => [:index]})

  menu(:top_menu,
       :travel_reports,
       {:controller => 'travel_reports', :action => 'index'},
       :caption => :travel_report_title,
       :if => Proc.new {
         User.current.allowed_to?(:travel_reports, nil, :global => true)
       })

end
