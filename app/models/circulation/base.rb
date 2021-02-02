# frozen_string_literal: true
class Circulation::Base < ApplicationRecord
  self.abstract_class = true
  self.table_name_prefix = 'circulation_'

  def self.colors
    { 'Architecture Library' => ['#0047b3', '#001f4d', '#005ce6'],
      'East Asian Library' => ['#b30000', '#660000', '#e60000'],
      'Engineering Library' => ['#ffa64d', '#cc6600', '#ffbf80'],
      'Firestone Library' => ['#00b33c', '#006622', '#00e64d'],
      'Lewis Library' => ['#7700b3', '#440066', '#9900e6'],
      'Lewis Science Library' => ['#7700b3', '#440066', '#9900e6'],
      'Mendel Library' => ['#ffff4d', '#e6e600', '#ffff80'],
      'Marquand Library' => ['#8080ff', '#3333ff', '#ccccff'],
      'Stokes Library' => ['#ff4da6', '#e60073', '#ffb3d9'],
      'Special Collections' => ['#80ffaa', '#1aff66', '#ccffdd'] }
  end

  def self.color_for_location(location, color_idx: 0)
    colors[location][color_idx]
  rescue NoMethodError => e
    Rails.logger.warn "No color for location #{location}"
    "#000000"
  end
end
