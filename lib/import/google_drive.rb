# frozen_string_literal: true
require "google/apis/drive_v3"
require "googleauth"

module Import
  class GoogleDrive
    SCOPES = ['https://www.googleapis.com/auth/drive.readonly'].freeze

    attr_reader :drive_service

    def initialize(drive_service: Google::Apis::DriveV3::DriveService.new, authorization: Google::Auth.get_application_default(SCOPES))
      @drive_service = drive_service
      drive_service.authorization = authorization
      drive_service.authorization.fetch_access_token!
    end

    def list_files
      response = drive_service.list_files(page_size: 10, fields: "nextPageToken, files(id, name)", include_team_drive_items: true, supports_all_drives: true)
    end

    def open_sheet(file_id:)
      drive_service.export_file(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") { |result, error| yield(result, error) }
    end

    def workbook(file_id:)
      workbook = nil
      open_sheet(file_id: file_id) do |result, err|
        if result
          workbook = RubyXL::Parser.parse_buffer(StringIO.new(result))
        else
          Rails.logger.warn("Error accessing file #{file_id}: #{err}")
        end
      end
      workbook
    end
  end
end
