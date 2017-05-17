namespace :setup do
  desc "setup entire project"
  task project: :environment do
    Rake::Task['db:migrate'].invoke
    Rake::Task['create_repositories:all'].invoke
    Rake::Task['import_metadata:all'].invoke
    Rake::Task['create_records:from_raw_records'].invoke
  end
end