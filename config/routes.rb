ActionController::Routing::Routes.draw do |map|
  map.travel_reports 'travel_reports.:format', :controller => 'travel_reports', :action => 'index'
end
