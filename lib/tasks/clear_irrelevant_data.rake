namespace :clear do
  desc 'Clear all Spotlight/devise-guest users'
  task :guest_users, [:days_old] => [:environment] do |_t, args|
    args.with_defaults(days_old: 7)
    User.where("guest = ? and updated_at < ?", true, args[:days_old].to_i.days.ago).find_each { |user| user.destroy }
  end

  desc 'Clear all old Spotlight saved searches'
  task :searches, [:days_old] => [:environment] do |_t, args|
    args.with_defaults(days_old: 7)
    Search.delete_old_searches(args[:days_old].to_i)
  end

  desc 'Orphaned records'
  task :orphans => [:environment] do 
    classes_to_search = [DcType, DcTitle, DcTermsSpacial, DcTermsIsPartOf, DcTermsExtent, DcSubject,
      DcSource, DcRight, DcResearchInterest, DcRelation, DcPublisher, DcLanguage, DcFormat,
      DcIdentifier, DcDescription, DcDate, DcCreator, DcCoverage, DcContributor,
      DcAdditionalDescription, DcAbstract]
    classes_to_search.each do |klass|
      puts "Clearing orphans in the #{klass.name} table..."
      klass.all.select{|item| item.record.nil? }.each(&:delete)
    end
  end
end
