# frozen_string_literal: true

require 'rake/testtask'
require 'database_cleaner'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |_t, args|
    require 'sequel/core'
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect('sqlite://db/sqlite.db') do |db|
      Sequel::Migrator.run(db, 'db/migrations', target: version)
    end
  end
end
