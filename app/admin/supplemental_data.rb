# frozen_string_literal: true
ActiveAdmin.register_page "SupplementalData" do
  menu if: proc { authorized?(:read, "SupplementalData") }, label: I18n.t("active_admin.supplemental_data"), parent: I18n.t("active_admin.resource_sharing")

  content title: proc { I18n.t("active_admin.supplemental_data") } do
    resource_collection = ActiveAdmin.application.namespaces[:admin].resources
    resources = resource_collection.select { |resource| resource.respond_to? :resource_class }
    resources = resources.select { |r| r.resource_name.name.in?(["Institution", "UpsZone", "GeoData::ZipCode"]) }
    resources = resources.sort { |a, b| a.resource_name.human <=> b.resource_name.human }

    render partial: 'index', locals: { resources: resources }
  end
end
