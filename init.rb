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
             'return_custom_field_id' => nil
           })

end
