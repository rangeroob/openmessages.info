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
require 'json'
require 'kramdown'
require 'password_blacklist'
require 'rack/cerberus'
require 'securerandom'
require 'sequel'
Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render
Cuba.use Rack::MethodOverride
Cuba.use Rack::Static, root: 'public', urls: ['/css']
Cuba.use Rack::Static, root: 'public', urls: ['/imgs']
Cuba.use Rack::Static, root: 'public', urls: ['/js']

Cuba.settings[:render][:template_engine] = 'html.erb'
Cuba.settings[:render][:views] = './views'

module API
  Cuba.use Rack::Session::Cookie, secret: Random.new_seed.to_s,
                                  oldsecret: Random.new_seed.to_s
  DB = Sequel.connect('sqlite://db/sqlite.db')
  data = DB[:data]
  user = DB[:user]
  revision = DB[:datarevisions]
  class GetMessage < Cuba; end
  GetMessage.define do
    on ':title' do |title|
      article = data.where(title: title).get(:textarea)
      @markdown2html = Kramdown::Document.new(article).to_html
      @html2markdown = Kramdown::Document.new(@markdown2html, input: 'html')
                                         .to_kramdown
    rescue NoMethodError
      res.status = 404
      res.redirect('/404')
    else
      res.write view('messages')
    end
  end
  class GetAllUserMessages < Cuba; end
  GetAllUserMessages.define do
    on ':username' do |username|
      @user_messages_title = data.where(username: username).select_map(:title)
      if @user_messages_title.any?
        @array = @user_messages_title.to_a
        res.write view('getallusermessages')
      elsif @user_messages_title.empty?
        res.redirect('/404')
      end
    end
  end
  class GetAllTitleRevisions < Cuba; end
  GetAllTitleRevisions.define do
    on ':title' do |title|
      @title_revisions = revision.where(title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '').to_s)
                                 .select_map(:edited_on)
      if @title_revisions.any?
        @array = @title_revisions.to_a
        res.write view('getallusermessages')
      elsif @title_revisions.empty?
        res.redirect('/404')
      end
    end
  end
  class EditMessage < Cuba; end
  EditMessage.define do
    on root, param('username'), param('password'), param('title'), param('textarea') do |username, password, title, textarea|
      check_password = BCrypt::Password.new(user.where(username: username).get(:password)).is_password?(password)
      if check_password == true
        DB.transaction do
          data.where(title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '').to_s)
          revision.insert(uuid: data.where(title: title.downcase.strip.tr(' ', '-')
          .gsub(/[^\w-]/, '').to_s).select(:uuid),
                          title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '').to_s,
                          textarea: textarea, edited_on: Time.now.to_i,
                          created_on: data.where(title: title.downcase.strip.tr(' ', '-')
                          .gsub(/[^\w-]/, '').to_s).get(:created_on),
                          username: data.where(title: title.downcase.strip.tr(' ', '-')
                  .gsub(/[^\w-]/, '').to_s).select(:username))
          data.where(title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '').to_s)
              .update(edited_on: Time.now.to_i, textarea: textarea)
        end
        res.redirect("/message/get/#{title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '')}")
      elsif check_password == false
        res.redirect('/put_error')
      end
    rescue BCrypt::Errors::InvalidHash
      res.redirect('/put_error')
    end
  end
  class DeleteMessage < Cuba; end
  DeleteMessage.define do
    on root, param('title'), param('username'), param('password') do |title, username, password|
      check_password = BCrypt::Password.new(user.where(username: username).get(:password)).is_password?(password)
      if check_password == true
        data.where(title: title, username: username).delete
        res.status = 200
      elsif check_password == false
        res.status = 404
      end
    rescue BCrypt::Error
      res.status = 500
    rescue Standard::Error
      res.status = 404
    end
  end
  class PutMessage < Cuba; end
  PutMessage.define do
    on root, param('username'), param('password'), param('title'), param('textarea') do |username, password, title, textarea|
      generate_id = SecureRandom.uuid
      begin
        check_password = BCrypt::Password.new(user.where(username: username).get(:password)).is_password?(password)
        if check_password == true
          DB.transaction do
            data.insert(uuid: generate_id.to_s, username: username.to_s,
                        title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, ''),
                        created_on: Time.now.to_i, edited_on: 0, textarea: textarea.to_s)
            revision.insert(uuid: generate_id.to_s, username: username.to_s,
                            title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, ''),
                            created_on: Time.now.to_i, edited_on: 0, textarea: textarea.to_s)
          end
          res.redirect("/message/get/#{title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '')}")
        elsif check_password == false
          res.redirect('/put_error')
        end
      rescue BCrypt::Errors::InvalidHash
        res.redirect('/put_error')
      end
    end
  end

  class Login < Cuba; end
  API::Login.use Rack::Cerberus, forgot_password_uri: nil, session_key: 'user' do |login, pass|
    check_password = BCrypt::Password.new(user.where(username: login).get(:password)).is_password?(pass)
    if check_password == true
      login == user.where(username: login).get(:username).to_s && BCrypt::Password.new(user.where(username: login).get(:password)).to_s
    elsif check_password == false
      print 'invaild-pass'
    end
  rescue BCrypt::Errors::InvalidHash
    print 'invaild-login'
  end
  Login.define do
    on root do
      res.redirect('/')
    end
    on 'secert' do
      run API::GetMessage
    end
    on 'hello' do
      on root do
        res.write('bye')
      end
    end
  end

  class SignUp < Cuba; end
  SignUp.define do
    on root, param('username'), param('password') do |username, password|
      checker = PasswordBlacklist::Checker.new
      if user.where(username: username).first
        @used_username = '<small> * Username already in use </small>'
        res.status = 500
        res.write view('/signup')
      elsif checker.blacklisted?(password) == true
        @blacklist_password = '<small> * The password provided is blacklisted </small>'
        res.status = 500
        res.write view('/signup')
      else
        bcrypted_password = BCrypt::Password.create(password)
        user.insert(username: username, password: bcrypted_password)
        hit_status = res.status = 200
        res.redirect('/') if hit_status
      end
    end
  end
end
