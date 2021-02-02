# frozen_string_literal: true
class GateCount::Base < ApplicationRecord
  self.abstract_class = true
  self.table_name_prefix = 'gate_count_'
end
