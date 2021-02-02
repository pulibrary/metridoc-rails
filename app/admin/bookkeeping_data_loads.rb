# frozen_string_literal: true
ActiveAdmin.register Bookkeeping::DataLoad do
  menu false
  permit_params :table_name, :earliest, :latest
end
