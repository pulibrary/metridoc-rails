# frozen_string_literal: true
class Report::TemplateJoinClause < ApplicationRecord
  validates :keyword, :table, :on_keys, presence: true
  belongs_to :report_template, class_name: "Report::Template"
  self.table_name = "report_template_join_clauses"
end
