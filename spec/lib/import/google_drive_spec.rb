# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Import::GoogleDrive, type: :model do
  let(:drive_service) { instance_double("Google::Apis::DriveV3::DriveService", authorization: auth) }
  let(:auth) { instance_double("Signet::OAuth2::Client", fetch_access_token!: true) }
  let(:file_id) { "1wNNrEVkDc6cLic7K6j5CYsQercm9vRMdQMY" }
  let(:drive) { described_class.new(drive_service: drive_service, authorization: auth) }
  #  let(:drive) { described_class.new }

  before do
    expect(drive_service).to receive(:authorization=).with(auth)
  end

  describe "#list_files" do
    let(:files) { [Google::Apis::DriveV3::File.new(id: 'abc123'), Google::Apis::DriveV3::File.new(id: 'def456')] }
    let(:file_list) { instance_double("Google::Apis::DriveV3::FileList", files: files) }
    let(:folder_id) { "folder_id_123" }
    it "allows you to list files in a drive" do
      expect(drive_service).to receive(:list_files).with(page_size: 10, fields: "nextPageToken, files(id, name, mimeType)", include_team_drive_items: true, supports_all_drives: true, q: "'#{folder_id}' in parents").and_return(file_list)
      file_list = drive.list_files(folder_id: folder_id)
      expect(file_list.files.count).to eq(2)
      expect(file_list.files.map(&:id)).to eq(['abc123', 'def456'])
    end
  end

  describe "#open_sheet" do
    it "Allows a sheet to be downloaded" do
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield("good result", false)
      drive.open_sheet(file_id: file_id) do |result, _err|
        expect(result.class).to eq(String)
      end
    end

    it "captures errors with a bad file id" do
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield(nil, Google::Apis::ClientError.new("error"))
      drive.open_sheet(file_id: file_id) do |result, err|
        expect(result).to be_nil
        expect(err.class).to eq(Google::Apis::ClientError)
      end
    end
  end

  describe "#workbook" do
    it "Allows a sheet to be downloaded" do
      data = File.new(Rails.root.join('spec', 'fixtures', "FTF-STF Stats Architecture.xlsx")).read
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield(data, false)
      result = drive.workbook(file_id: file_id)
      expect(result.class).to eq(RubyXL::Workbook)
    end

    it "captures errors with a bad file id" do
      expect(drive_service).to receive(:export_file).with(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet").and_yield(nil, Google::Apis::ClientError.new("error"))
      drive = described_class.new(drive_service: drive_service, authorization: auth)
      result = drive.workbook(file_id: file_id)
      expect(result).to be_nil
    end
  end

  describe "#csv" do
    it "Allows a csv to be downloaded" do
      data = File.new(Rails.root.join('spec', 'fixtures', "lc_space.csv")).read
      expect(drive_service).to receive(:get_file).with(file_id, hash_including(supports_team_drives: true, download_dest: instance_of(StringIO))).and_yield(data, false)
      result = drive.csv(file_id: file_id)
      expect(result.class).to eq(CSV)
    end

    it "captures errors with a bad file id" do
      expect(drive_service).to receive(:get_file).with(file_id, hash_including(supports_team_drives: true, download_dest: instance_of(StringIO))).and_yield(nil, Google::Apis::ClientError.new("error"))
      drive = described_class.new(drive_service: drive_service, authorization: auth)
      result = drive.csv(file_id: file_id)
      expect(result).to be_nil
    end
  end
end
