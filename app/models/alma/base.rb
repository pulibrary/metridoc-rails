# frozen_string_literal: true
module Alma
  class Base < ApplicationRecord
    self.abstract_class = true
    self.table_name_prefix = 'alma_'
  end
end
