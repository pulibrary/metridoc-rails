ActiveAdmin.register Circulation::SeatsRequest do
  menu false
  permit_params :location, :zone, :from_date, :from_time, :to_date, :to_time, :created_date, :created_time, :status
end