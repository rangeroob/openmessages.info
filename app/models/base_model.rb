# frozen_string_literal: true

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'bcrypt'
require 'cuba'
require 'cuba/safe'
require 'cuba/render'
require 'date'
require 'erb'
require 'fileutils'
require 'net/http'
require 'json'
require 'kramdown'
require 'password_blacklist'
require 'securerandom'
require 'sequel'
require_relative 'authentication'
require_relative 'databasetransactions'
require_relative 'wikiarticles'
Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render
Cuba.use Rack::MethodOverride
Cuba.use Rack::Static, root: 'public', urls: ['/css']
Cuba.use Rack::Static, root: 'public', urls: ['/imgs']
Cuba.use Rack::Static, root: 'public', urls: ['/js']

Cuba.settings[:render][:template_engine] = 'html.erb'
Cuba.settings[:render][:views] = 'app/views'

Cuba.plugin Model::Authentication
Cuba.plugin Model::DatabaseTransactions
Cuba.plugin Model::WikiArticles
@session = Cuba.use Rack::Session::Cookie, secret: Random.new_seed.to_s,
                                           oldsecret: Random.new_seed.to_s
DB = Sequel.connect('sqlite://db/sqlite.db')
DataTable = DB[:data]
UserTable = DB[:user]
RevisionTable = DB[:datarevisions]
