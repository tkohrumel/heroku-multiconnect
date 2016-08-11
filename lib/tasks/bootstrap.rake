desc "Run all bootstrapping tasks upon initial Heroku build"
task :bootstrap_heroku_app => :environment do
  Rake::Task["db:create"].invoke
  Rake::Task["db:migrate"].invoke
end