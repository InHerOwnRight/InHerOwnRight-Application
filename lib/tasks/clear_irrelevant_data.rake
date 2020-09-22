namespace :clear do
  desc 'Clear all Spotlight/devise-guest users'
  task guest_users: :environment do
    User.where(guest: true).each { |user| user.destroy }
  end

  desc 'Clear all old Spotlight saved searches'
  task searches: :environment do
    Search.all.each { |search| search.destroy }
  end
end
