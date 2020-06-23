# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'dummy/config/environment.rb'
require 'rails/test_help'
require 'minitest/pride'

# Run migrations for in-memory SQLite database
ActiveRecord::Migration.verbose = false
if ActiveRecord.version.release() < Gem::Version.new('5.2.0')
  ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate/', __FILE__))
elsif ActiveRecord.version.release() < Gem::Version.new('6.0.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate/', __FILE__)).migrate
else
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate/', __FILE__), ActiveRecord::SchemaMigration).migrate
end

Rails.backtrace_cleaner.remove_silencers!
