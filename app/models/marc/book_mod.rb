# frozen_string_literal: true
module Marc
  class BookMod < ApplicationRecord
    self.table_name_prefix = 'marc_'
  end
end
