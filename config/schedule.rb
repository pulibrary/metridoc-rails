# frozen_string_literal: true

set :output, "log/cron.log"
env :PATH, ENV["PATH"]
job_type :rake, "cd :path && :environment_variable=:environment :bundle_command rake :task :output"

every '00 17 * * 1', roles: [:app] do
  rake "import -c circulation"
end

every '30 17 * * 1', roles: [:app] do
  rake "transfer_results:seats"
end
