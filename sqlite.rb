require 'fileutils'
require 'sequel'

FileUtils.mkdir 'db' unless Dir.exist?('db')
DB = Sequel.connect('sqlite://db/sqlite.db') # requires sqlite3

# create an items table
DB.create_table :data do
  primary_key :id
  String :uuid
  String :username
  Blob :textarea
end

DB.create_table :user do
  String :username
  String :password
end
DB.add_index :data, %i[uuid username]
