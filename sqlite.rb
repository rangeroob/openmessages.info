require 'bcrypt'
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
data = DB[:data]
user = DB[:user]

bcrypted_password = BCrypt::Password.create('johndoe1')
user.insert(username: 'johndoe', password: bcrypted_password)
data.insert(uuid: 'a', username: 'johndoe', textarea: '#Hello')

