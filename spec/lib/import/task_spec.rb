require 'rails_helper'

RSpec.describe Import::Task, type: :model do
  it "imports a seats csv file" do
    main = Import::Main.new(config_folder: "circulation")
    main.global_config["import_folder"] = Rails.root.join('spec','fixtures')
    task_filename = Rails.root.join('config','data_sources','circulation', '09_seats_requests.yml')
    t = described_class.new(main, task_filename, true) 
    expect { t.execute }.to change{ Circulation::SeatsRequest.count }.by(2)
    first_row = Circulation::SeatsRequest.first
    expect(first_row.from).to eq(Chronic.parse("2021-01-21 10:00"))
    expect(first_row.to).to eq(Chronic.parse("2021-01-21 16:00"))
    expect(first_row.created).to eq(Chronic.parse("2021-01-18 00:38"))
    expect(first_row.name).to eq('East Reading Room / East Reading Room Seat 7')
  end

  it "imports a pickup file" do
    main = Import::Main.new(config_folder: "circulation")
    main.global_config["import_folder"] = Rails.root.join('spec','fixtures')
    task_filename = Rails.root.join('config','data_sources','circulation', '01_pick_up_requests.yml')
    t = described_class.new(main, task_filename, true) 
    expect { t.execute }.to change{ Circulation::PickUpRequest.count }.by(2)
    first_row = Circulation::PickUpRequest.first
    expect(first_row.date).to eq(Chronic.parse("Monday, September 14, 2020"))
    expect(first_row.location).to eq('Firestone Library')
    expect(first_row.received).to eq(176)
  end
end
