# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Util, type: :model do
  describe "#column_to_attribute" do
    it "cleans up the column name" do
      expect(described_class.column_to_attribute("Reshelved or returned to ReCAP / Annex  because not picked up")).to eq('reshelved_or_returned_to_re_cap_annex_because_not_picked_up')
    end
  end

  describe "#valid_integer?" do
    it "marks string as invalid" do
      expect(described_class.valid_integer?("abc")).to be_falsey
    end

    it "marks positive integer as valid" do
      expect(described_class.valid_integer?("23")).to be_truthy
      expect(described_class.valid_integer?("+23")).to be_truthy
    end

    it "marks negative integer as valid" do
      expect(described_class.valid_integer?("-23")).to be_truthy
    end

    it "marks float as valid with .0 as valid" do
      expect(described_class.valid_integer?("5.0")).to be_truthy
    end

    it "marks float as valid with .5 as invalid" do
      expect(described_class.valid_integer?("5.5")).to be_falsey
    end

    it "marks negative float as valid" do
      expect(described_class.valid_integer?("-5.0")).to be_truthy
    end
  end
end
