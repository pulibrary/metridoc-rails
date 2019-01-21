ActiveAdmin.register Keyserver::PurchaseItem do
  menu false
  permit_params :purchase_id, :purchase_server_id, :purchase_order_id, :purchase_name, :purchase_status, :purchase_type, :purchase_entitlement_type, :purchase_metric, :purchase_folder_id, :purchase_entitlements_per_package, :purchase_start_date, :purchase_end_date, :purchase_renew_date, :purchase_currency, :purchase_extended_cost, :purchase_converted_cost, :purchase_unit_msrp, :purchase_unit_price, :purchase_product_id, :purchase_effective_product_id, :purchase_invoice, :purchase_division_id, :purchase_contract_id, :purchase_group, :purchase_site, :purchase_cost_center, :purchase_reseller_sku, :purchase_manufacturer_sku, :purchase_external_id, :purchase_location, :purchase_reference, :purchase_conditions, :purchase_description, :purchase_notes, :purchase_flags
  actions :all, :except => [:edit, :update, :destroy]
end
