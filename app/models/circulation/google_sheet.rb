# frozen_string_literal: true
require "google/apis/sheets_v4"
require "googleauth"

module Circulation
  class GoogleSheet
    SCOPES = [Google::Apis::SheetsV4::AUTH_SPREADSHEETS].freeze

    attr_reader :sheet_service

    def initialize(sheet_service: Google::Apis::SheetsV4::SheetsService.new, authorization: Google::Auth.get_application_default(SCOPES))
      @sheet_service = sheet_service
      sheet_service.authorization = authorization
      sheet_service.authorization.fetch_access_token!
    end

    def add_data(file_id:, data:, range:)
      # Add columns to spresdsheet
      col_range = Google::Apis::SheetsV4::ValueRange.new(values: data)

      result = sheet_service.update_spreadsheet_value(file_id,
                                          range,
                                          col_range,
                                          value_input_option: 'RAW')
      data.count == result.updated_rows
    rescue Google::Apis::ClientError => e
      Rails.logger.warn("Can not update sheet #{file_id}. #{e.message}")
      false
    end
  end
end
