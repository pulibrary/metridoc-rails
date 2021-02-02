# frozen_string_literal: true
module ApplicationHelper
  def self.mac_address
    platform = RUBY_PLATFORM.downcase
    output = `#{platform =~ /win32/ ? 'ipconfig /all' : 'ifconfig'}`
    case platform
    when /darwin/
      Regexp.last_match(1) if output =~ /en1.*?(([A-F0-9]{2}:){5}[A-F0-9]{2})/im
    when /win32/
      Regexp.last_match(1) if output =~ /Physical Address.*?(([A-F0-9]{2}-){5}[A-F0-9]{2})/im
    when /linux/
      Regexp.last_match(1) if output =~ /ether\s+(([A-F0-9]{2}:){5}[A-F0-9]{2})/im
        # Cases for other platforms...
      end
  end
end
