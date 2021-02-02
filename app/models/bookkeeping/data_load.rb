# frozen_string_literal: true
module Bookkeeping
  class DataLoad < ApplicationRecord
    self.table_name_prefix = 'bookkeeping_'
  end
end
