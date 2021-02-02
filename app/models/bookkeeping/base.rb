# frozen_string_literal: true
module Bookkeeping
  class Base < ApplicationRecord
    self.abstract_class = true
    self.table_name_prefix = 'bookkeeping_'
  end
end
