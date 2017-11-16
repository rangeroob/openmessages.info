require 'cuba'
require 'cuba/safe'
require 'cuba/render'
require 'erb'
require 'fileutils'
require 'json'
require 'kramdown'
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
  class GetMessage < Cuba; end
  GetMessage.define do
    on ':uuid' do |uuid|
      begin
        article = data.where(uuid: uuid).get(:textarea)
        @markdown2html = Kramdown::Document.new(article).to_html
      rescue NoMethodError
        res.status = 404
        res.redirect('/404')
      else
        res.write partial('messages')
      end
    end
  end
  class GetAllUserMessages < Cuba; end
  GetAllUserMessages.define do
    on ':email' do |email|
      @user_messages_uuid = data.where(email: email).select_map(:uuid)
      @array = @user_messages_uuid.to_a
      res.write partial('getallusermessages')
    end
  end
  class DeleteMessage < Cuba; end
  DeleteMessage.define do
    on root, param('uuid'), param('email') do |uuid, email|
      if data.where(uuid: uuid, email: email).first
      data.where(uuid: uuid, email: email).delete
      res.status = 200
      elsif data.where(uuid: !uuid) || data.where(email: !email)
        res.status = 404
    end
  end
  end
  class PutMessage < Cuba; end
  PutMessage.define do
    on root, param('name'), param('email'), param('textarea') do |name, email, textarea|
      generate_id = SecureRandom.uuid
      data.insert(uuid: generate_id.to_s, name: name.to_s, email: email.to_s,
                  textarea: textarea.to_s)
      create_status = res.status = 201
      res.redirect("/message/get/#{generate_id}") if create_status
    end
  end
end

module FRONTEND
  class Root < Cuba; end
  Root.define do
    on root do
      res.write view('layout')
    end
  end

  class FourOFour < Cuba; end
  FourOFour.define do
    on root do
      res.write partial('404')
    end
  end
end

Cuba.define do
  on put do
    on 'message/put' do
      run API::PutMessage
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
    on 'message' do
      run API::GetMessage
    end
    on 'message/user' do
      run API::GetAllUserMessages
    end
  end
end
