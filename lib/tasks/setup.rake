namespace :setup do
  desc "setup entire project"
  task project: :environment do
    Rake::Task['db:migrate'].invoke
    Rake::Task['create_repositories:all'].invoke
    Rake::Task['import_metadata:all'].invoke
    Rake::Task['create_records:all'].invoke
    Rake::Task['import_images:all'].invoke
    Rake::Task['sunspot:reindex'].invoke
  end
end