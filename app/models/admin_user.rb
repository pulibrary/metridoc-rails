# frozen_string_literal: true
class AdminUser < ApplicationRecord
  belongs_to :user_role, class_name: "Security::UserRole", optional: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  def to_xml(options = {})
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(indent: options[:indent])
    xml.admin_user do
      xml.tag!(:id, id)
      xml.tag!(:email, email)
      xml.tag!(:created_at, created_at)
      xml.tag!(:updated_at, updated_at)
    end
  end

  def authorized?(action, subject)
    return true if super_admin?

    # check for edit_profile
    return true if subject == self

    return !Security::UserRole.subject_secured?(subject) if user_role.blank?

    user_role.authorized?(action, subject)
  end

  def full_name
    first_name.blank? && last_name.blank? ? email.to_s : [first_name, last_name].join(" ")
  end

  def can_edit_system_admin_attribute?(admin_user)
    system_admin? && admin_user != self
  end

  protected

  def password_required?
    encrypted_password.blank?
  end
end
