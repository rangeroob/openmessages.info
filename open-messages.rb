# frozen_string_literal: true

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'bcrypt'
require 'cuba'
require 'cuba/safe'
require 'cuba/render'
require 'erb'
require 'fileutils'
require 'json'
require 'kramdown'
require 'password_blacklist'
require 'securerandom'
require 'sequel'

Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render
Cuba.use Rack::Session::Cookie, secret: Random.new_seed.to_s
Cuba.use Rack::MethodOverride
Cuba.use Rack::Static, root: 'public', urls: ['/css']
Cuba.use Rack::Static, root: 'public', urls: ['/imgs']
Cuba.use Rack::Static, root: 'public', urls: ['/js']

Cuba.settings[:render][:template_engine] = 'html.erb'
Cuba.settings[:render][:views] = './views'

module API
  DB = Sequel.connect('sqlite://db/sqlite.db')
  data = DB[:data]
  user = DB[:user]
  class GetMessage < Cuba; end
  GetMessage.define do
    on ':title' do |title|
      article = data.where(title: title).get(:textarea)
      @markdown2html = Kramdown::Document.new(article).to_html
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
  class EditMessage < Cuba; end
  EditMessage.define do
    on root, param('username'), param('password'), param('title'), param('textarea') do |username, password, title, textarea|
      check_password = BCrypt::Password.new(user.where(username: username).get(:password)).is_password?(password)
      if check_password == true
        DB.transaction do
          data.where(title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '').to_s)
              .update(textarea: textarea)
          data.where(title: title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '').to_s)
              .update(edited_on: Date.today.to_s)
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
          data.insert(uuid: generate_id.to_s, username: username.to_s,
                      title: title, textarea: textarea.to_s)
          res.redirect("/message/get/#{title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '')}")
        elsif check_password == false
          res.redirect('/put_error')
        end
      rescue BCrypt::Errors::InvalidHash
        res.redirect('/put_error')
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
module FRONTEND
  class Root < Cuba; end
  Root.define do
    on root do
      res.write view('home')
    end
  end

  class FourOFour < Cuba; end
  FourOFour.define do
    on root do
      res.write partial('404')
    end
  end

  class FrontendPutError < Cuba; end
  FrontendPutError.define do
    on root do
      @invalid_username_password = '<small>* Invalid Username/Password given</small>'
      res.write view('home')
    end
  end

  class FrontendSignup < Cuba; end
  FrontendSignup.define do
    on root do
      res.write view('signup')
    end
  end
end

Cuba.define do
  on put do
    on 'message/put' do
      run API::PutMessage
    end
    on 'message/edit' do
      run API::EditMessage
    end
  end
  on post do
    on 'message/signup' do
      run API::SignUp
    end
  end
  on delete do
    on 'message/delete' do
      run API::DeleteMessage
    end
  end
  on get do
    on root do
      on csrf.unsafe? do
        csrf.reset!
        res.status = 403
        res.write('Not authorized')
        halt(res.finish)
      end
      run FRONTEND::Root
    end
    on '404' do
      run FRONTEND::FourOFour
    end
    on 'message/get' do
      run API::GetMessage
    end
    on 'message/user' do
      run API::GetAllUserMessages
    end
    on 'put_error' do
      run FRONTEND::FrontendPutError
    end
    on 'signup' do
      on csrf.unsafe? do
        csrf.reset!
        res.status = 403
        res.write('Not authorized')
        halt(res.finish)
      end
      run FRONTEND::FrontendSignup
    end
  end
end
