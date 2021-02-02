# frozen_string_literal: true
ActiveAdmin.register Ezborrow::PatronType do
  menu false
  permit_params :patron_type, :patron_type_desc, :ezb_patron_type_id
  actions :all, except: [:new, :edit, :update, :destroy]

  preserve_default_filters!

  filter :patron_type, filters: [:contains, :not_cont, :starts_with, :ends_with, :equals]
  filter :patron_type_desc, filters: [:contains, :not_cont, :starts_with, :ends_with, :equals]
  filter :ezb_patron_type_id, filters: [:contains, :not_cont, :starts_with, :ends_with, :equals]
end
