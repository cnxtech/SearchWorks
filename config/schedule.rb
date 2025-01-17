# Learn more: http://github.com/javan/whenever

# Note that there's also a prune_old_search_data task that's managed by puppet

set :output, 'log/cron.log'

every 1.hours, roles: %i[app] do
  rake 'searchworks:prune_eds_cache'
end

every '0 0 1,15 * *', roles: %i[app] do # biweekly
  rake 'searchworks:clear_eds_cache'
end
