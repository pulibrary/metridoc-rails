ActiveAdmin.register_page "Circulation" do
  content do
    resource_collection = ActiveAdmin.application.namespaces[:admin].resources
    resources = resource_collection.select { |resource| resource.respond_to? :resource_class }
    resources = resources.select{|r| /^Circulation::/.match(r.resource_name.name) }
    resources = resources.sort{|a,b| a.resource_name.human <=> b.resource_name.human }
    permitted_params = params.permit(:pick_up_weeks_ago, :seats_weeks_ago )
    pick_up_weeks_ago_param = permitted_params[:pick_up_weeks_ago]
    pick_up_weeks_ago = pick_up_weeks_ago_param.to_i if pick_up_weeks_ago_param.present?
    pick_up_weeks_ago ||= 1 
    seats_weeks_ago_param = permitted_params[:seats_weeks_ago]
    seats_weeks_ago = seats_weeks_ago_param.to_i if seats_weeks_ago_param.present?
    seats_weeks_ago ||= 6
    render partial: 'index', locals: {resources: resources, pick_up_weeks_ago: pick_up_weeks_ago, seats_weeks_ago: seats_weeks_ago}
  end
end
