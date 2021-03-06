# frozen_string_literal: true
ActiveAdmin.register GoogleAnalytics::Referral do
  menu false
  permit_params :source, :users, :new_users, :sessions
end
