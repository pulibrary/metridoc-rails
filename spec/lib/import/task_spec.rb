# frozen_string_literal: true
require 'rails_helper'
require "google/apis/drive_v3"

RSpec.describe Import::Task, type: :model do
  let(:main) do
    main = Import::Main.new(config_folder: "circulation")
    main.global_config["import_folder"] = Rails.root.join('spec', 'fixtures')
    main
  end

  it "imports a seats csv file" do
    task_filename = Rails.root.join('config', 'data_sources', 'circulation', '09_seats_requests.yml')
    t = described_class.new(main, task_filename, true)
    expect { t.execute }.to change { Circulation::SeatsRequest.count }.by(2)
    first_row = Circulation::SeatsRequest.first
    expect(first_row.from).to eq(Chronic.parse("2021-01-21 10:00"))
    expect(first_row.to).to eq(Chronic.parse("2021-01-21 16:00"))
    expect(first_row.created).to eq(Chronic.parse("2021-01-18 00:38"))
    expect(first_row.name).to eq('East Reading Room / East Reading Room Seat 7')
  end

  it "imports a pickup file" do
    task_filename = Rails.root.join('spec', 'fixtures', '01_pick_up_requests.yml')
    t = described_class.new(main, task_filename, true)
    expect { t.execute }.to change { Circulation::PickUpRequest.count }.by(2)
    first_row = Circulation::PickUpRequest.first
    expect(first_row.date).to eq(Chronic.parse("Monday, September 14, 2020"))
    expect(first_row.location).to eq('Firestone Library')
    expect(first_row.received).to eq(176)
  end

  context "google drive" do
    let(:drive_service) { instance_double("Google::Apis::DriveV3::DriveService", authorization: auth) }
    let(:auth) { instance_double("Signet::OAuth2::Client", fetch_access_token!: true) }
    let(:file_id) { "1wNNrEVkDc6cLic7K6j5CYsQercm9vRMdQMY" }
    let(:drive) { Import::GoogleDrive.new(drive_service: drive_service, authorization: auth) }

    before do
      expect(drive_service).to receive(:authorization=).with(auth)
    end

    it "imports a google drive file" do
      task_filename = Rails.root.join('config', 'data_sources', 'circulation', '03_pick_up_requests.yml')
      ENV["FALL_STATS_FILE_ID"] = "folder123"
      data = File.new(Rails.root.join('spec', 'fixtures', "FTF-STF Stats Architecture.xlsx")).read
      expect(drive).to receive(:open_sheet).with(file_id: "folder123").and_yield(data, false)
      t = described_class.new(main, task_filename, true, google_drive: drive)
      expect { t.execute }.to change { Circulation::PickUpRequest.count }.by(2)
      first_row = Circulation::PickUpRequest.first
      expect(first_row.date).to eq(DateTime.parse("Monday, September 14, 2020"))
      expect(first_row.location).to eq('Architecture Library')
      expect(first_row.received).to eq(9)
      expect(first_row.local_processed).to eq(9)
      expect(first_row.offsite_processed).to eq(3)
      expect(first_row.abandoned).to eq(0)
      last_row = Circulation::PickUpRequest.last
      expect(last_row.date).to eq(DateTime.parse("Tuesday, September 15, 2020"))
      expect(last_row.location).to eq('Architecture Library')
      expect(last_row.received).to eq(6)
      expect(last_row.local_processed).to eq(5)
      expect(last_row.offsite_processed).to eq(1)
      expect(last_row.abandoned).to eq(0)
    end

    it "imports a google csv folder" do
      main.global_config["import_folder"] = Rails.root.join('spec', 'fixtures')
      task_filename = Rails.root.join('config', 'data_sources', 'circulation', '10_seats_requests.yml')
      ENV["SEATS_FOLDER_ID"] = "folder123"
      files = [Google::Apis::DriveV3::File.new(id: 'abc123', mime_type: 'text/csv'), Google::Apis::DriveV3::File.new(id: 'def456', mime_type: 'text/csv')]
      file_list = instance_double("Google::Apis::DriveV3::FileList", files: files)
      data = File.new(Rails.root.join('spec', 'fixtures', "lc_space.csv"))
      expect(drive).to receive(:list_files).with(folder_id: "folder123").and_return(file_list)
      expect(drive).to receive(:open_csv).with(file_id: "abc123").and_yield(data, false)
      expect(drive).to receive(:open_csv).with(file_id: "def456").and_yield(data, false)
      t = described_class.new(main, task_filename, true, google_drive: drive)
      expect { t.execute }.to change { Circulation::SeatsRequest.count }.by(4)
      first_row = Circulation::SeatsRequest.first
      expect(first_row.from).to eq(Chronic.parse("2021-01-21 10:00"))
      expect(first_row.to).to eq(Chronic.parse("2021-01-21 16:00"))
      expect(first_row.created).to eq(Chronic.parse("2021-01-18 00:38"))
      expect(first_row.name).to eq('East Reading Room / East Reading Room Seat 7')
      last_row = Circulation::SeatsRequest.last
      expect(last_row.from).to eq(Chronic.parse("2021-01-15 10:30"))
      expect(last_row.to).to eq(Chronic.parse("2021-01-15 17:00"))
      expect(last_row.created).to eq(Chronic.parse("2021-01-14 13:05"))
      expect(last_row.name).to eq('Discovery Hub / Discovery Hub Seat 10')
    end
  end
end
