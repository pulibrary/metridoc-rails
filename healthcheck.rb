#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'

uri = URI('http://localhost/')
res = Net::HTTP.get_response(uri)

exit res.is_a?(Net::HTTPOK) ? 0 : 1
