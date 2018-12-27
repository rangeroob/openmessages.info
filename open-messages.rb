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
require 'securerandom'
require 'sequel'
require_relative 'API'
Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render
Cuba.use Rack::MethodOverride
Cuba.use Rack::Static, root: 'public', urls: ['/css']
Cuba.use Rack::Static, root: 'public', urls: ['/imgs']
Cuba.use Rack::Static, root: 'public', urls: ['/js']

Cuba.settings[:render][:template_engine] = 'html.erb'
Cuba.settings[:render][:views] = './views'

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
    on 'auth' do
      run API::Login
    end
    on 'message/get' do
      run API::GetMessage
    end
    on 'message/user' do
      run API::GetAllUserMessages
    end
    #on 'message/title' do
    #  run API::GetAllTitleRevisions
    #end
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
