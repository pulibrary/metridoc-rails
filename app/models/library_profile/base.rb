# frozen_string_literal: true
class LibraryProfile::Base < ApplicationRecord
  self.abstract_class = true
  self.table_name_prefix = 'library_profile_'
end
