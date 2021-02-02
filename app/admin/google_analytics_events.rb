# frozen_string_literal: true
ActiveAdmin.register GoogleAnalytics::Event do
  menu false
  permit_params :category, :action, :label, :total
end
