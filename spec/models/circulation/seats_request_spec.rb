# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Circulation::SeatsRequest, type: :model do
  let(:a_week_ago) {1.weeks.ago.beginning_of_week}
  let(:two_weeks_ago) {2.weeks.ago.beginning_of_week}

  describe "#gather_data" do
    it "gathers no data for an empty range" do
      expect(described_class.gather_data(date_range: a_week_ago..1.weeks.ago.end_of_week)).to eq([])
    end

    it "gathers data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by patron")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      expect(described_class.gather_data(date_range: a_week_ago..1.weeks.ago.end_of_week)).to eq(
        [{:color=>"#000000", :data=>{a_week_ago.to_date=>2}, :name=>"Firestone, Cancelled", :stack=>"Firestone"},
         {:color=>"#000000", :data=>{a_week_ago.to_date=>3}, :name=>"Firestone, Confirmed", :stack=>"Firestone"},
         {:color=>"#000000", :data=>{a_week_ago.to_date=>1}, :name=>"Lewis, Confirmed", :stack=>"Lewis"}])
    end
  end

  describe "#gather_status_data" do
    it "gathers no data for an empty range" do
      expect(described_class.gather_status_data(date_range: a_week_ago..1.weeks.ago.end_of_week)).to eq({})
    end

    it "gathers data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by patron")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      expect(described_class.gather_status_data(date_range: a_week_ago..1.weeks.ago.end_of_week)).to eq(
        {["Firestone", "Cancelled by other"] => 1,
         ["Firestone", "Cancelled by patron"] => 1,
         ["Firestone", "Confirmed"] => 3,
         ["Lewis", "Confirmed"] => 1})
    end
  end

  describe "#gather_tabular_data" do
    it "gathers no data for an empty range" do
      expect(described_class.gather_tabular_data(date_range: a_week_ago..1.weeks.ago.end_of_week)).to eq([])
    end

    it "gathers data for a range" do
      described_class.create(from: two_weeks_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: two_weeks_ago, location: "Lewis", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Confirmed")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by patron")
      described_class.create(from: a_week_ago, location: "Firestone", status: "Cancelled by other")
      described_class.create(from: a_week_ago, location: "Lewis", status: "Confirmed")
      expect(described_class.gather_tabular_data(date_range: two_weeks_ago..1.weeks.ago.end_of_week)).to eq(
        { a_week_ago.to_date => {"Firestone" => { "Cancelled" =>2, "Confirmed" =>3}, "Lewis" => { "Cancelled" =>0, "Confirmed" =>1}},
          two_weeks_ago.to_date => {"Firestone" => { "Cancelled" =>0, "Confirmed" =>1}, "Lewis" => { "Cancelled" =>0, "Confirmed" =>1}}})
    end
  end

end
