# frozen_string_literal: true
require "google/apis/drive_v3"
require "googleauth"

module Import
  class GoogleDrive
    SCOPES = ['https://www.googleapis.com/auth/drive'].freeze

    attr_reader :drive_service

    def initialize(drive_service: Google::Apis::DriveV3::DriveService.new, authorization: Google::Auth.get_application_default(SCOPES))
      @drive_service = drive_service
      drive_service.authorization = authorization
      drive_service.authorization.fetch_access_token!
    end

    def list_files(folder_id:)
      response = drive_service.list_files(page_size: 10, fields: "nextPageToken, files(id, name, mimeType)", include_team_drive_items: true, supports_all_drives: true, q: "'#{folder_id}' in parents")
    end

    def open_sheet(file_id:)
      drive_service.export_file(file_id, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") { |result, error| yield(result, error) }
    end

    def open_csv(file_id:)
      output = StringIO.new
      drive_service.get_file(file_id, download_dest: output, supports_team_drives: true) do |_result, error|
        if error
          yield(nil, error)
        else
          yield(output, error)
        end
      end
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

    def csv(file_id:, header_converters: nil)
      csv = nil
      open_csv(file_id: file_id) do |result, err|
        if result
          result.rewind
          result_data = result.read.sub("\xEF\xBB\xBF", '')
          csv = CSV.new(result_data, headers: true, header_converters: header_converters)
        else
          Rails.logger.warn("Error accessing file #{file_id}: #{err}")
        end
      end
      csv
    end
  end
end
