# frozen_string_literal: true
module Ares
  class Base < ApplicationRecord
    self.abstract_class = true
    self.table_name_prefix = 'ares_'
  end
end
