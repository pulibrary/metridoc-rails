# frozen_string_literal: true
class Security::UserRole < ApplicationRecord
  has_many :admin_users
  has_many :user_role_sections, class_name: "Security::UserRoleSection"

  accepts_nested_attributes_for :user_role_sections, allow_destroy: true, reject_if: proc { |attributes| attributes['section'].blank? }

  MANAGED_SECTIONS = ["Security",
                      "Alma",
                      "Borrowdirect",
                      "EzBorrow",
                      "GateCount",
                      "Illiad",
                      "Keyserver",
                      "Marc",
                      "LibraryProfile",
                      "SupplementalData",
                      "Log",
                      "Bookkeeping",
                      "Tools",
                      "Misc",
                      "Report"].freeze
  ACCESS_LEVELS = ["read-only", "read-write"].freeze

  def authorized?(action, subject)
    return true unless Security::UserRole.subject_secured?(subject)

    s = Security::UserRole.translate_subject_to_section(subject)
    access_level = action == :read ? ['read-only', 'read-write'] : 'read-write'

    puts "checking: #{s} - #{access_level} - #{action}"

    user_role_sections.of_section_access_level(s, access_level).present?
  end

  def self.subject_secured?(subject)
    translate_subject_to_section(subject).in?(MANAGED_SECTIONS)
  end

  def self.translate_subject_to_section(subject)
    s = if subject.is_a?(Class)
          subject
        elsif subject.class.to_s != "String"
          subject.class
        else
          subject
        end

    if (m = s.to_s.match(/(?<module>[^\:]+)\:\:/))
      s = m[:module]
    end

    s = "Security" if s.to_s == "AdminUser"
    s = "SupplementalData" if s.to_s.in?(["UpsZone", "GeoData::ZipCode", "Institution"])

    s.to_s
  end

  def self.section_select_options
    MANAGED_SECTIONS.sort_by { |e| Security::UserRoleSection.section_humanized_name(e).upcase }.map { |e| [Security::UserRoleSection.section_humanized_name(e), e] }
  end

  def user_role_sections_sorted
    user_role_sections.sort_by { |a| Security::UserRoleSection.section_humanized_name(a.section) }
  end
end
