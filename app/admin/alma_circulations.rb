# frozen_string_literal: true
ActiveAdmin.register Alma::Circulation do
  menu false
  actions :all, except: [:new, :edit, :update, :destroy]

  preserve_default_filters!
end
