# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'dummy/config/environment.rb'
require 'rails/test_help'
require 'minitest/pride'

# Run migrations for in-memory SQLite database
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate/', __FILE__))

Rails.backtrace_cleaner.remove_silencers!
