# Load the rails application
require File.expand_path('../application', __FILE__)

Dummy::Application.load_tasks
Rake::Task['ubiquo:install'].invoke
Rake::Task['db:create'].invoke
ActiveRecord::Migrator.migrate File.expand_path("../db/migrate/", __FILE__)

Dummy::Application.initialize!
