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
require_relative 'models/base_model'
require_relative 'controllers/404'
require_relative 'controllers/deletewiki'
require_relative 'controllers/editwiki'
require_relative 'controllers/getalluserwikis'
require_relative 'controllers/getrevision'
require_relative 'controllers/gettalltitlerevisions'
require_relative 'controllers/getwiki'
require_relative 'controllers/putwiki'
require_relative 'controllers/puterror'
require_relative 'controllers/root'
require_relative 'controllers/login'
require_relative 'controllers/logout'
require_relative 'controllers/signup'

Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render
Cuba.use Rack::MethodOverride
Cuba.use Rack::Static, root: 'public', urls: ['/css']
Cuba.use Rack::Static, root: 'public', urls: ['/imgs']
Cuba.use Rack::Static, root: 'public', urls: ['/js']

Cuba.settings[:render][:template_engine] = 'html.erb'
Cuba.settings[:render][:views] = './views'

Cuba.define do
  on put do
    on 'wiki/put' do
      run Controller::PutWiki
    end
    on 'wiki/edit' do
      run Controller::EditWiki
    end
  end

  on post do
    on 'signup' do
      run Controller::SignUp
    end
    on 'login' do
      run Controller::Login
    end
  end

  on delete do
    on 'wiki/delete' do
      run Controller::DeleteWiki
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
      run Controller::Root
    end

    on '404' do
      run Controller::FourOFour
    end

    on 'login' do
      on csrf.unsafe? do
        csrf.reset!
        res.status = 403
        res.write('Not authorized')
        halt(res.finish)
      end
      run Controller::Login
    end

    on 'logout' do
      run Controller::Logout
    end

    on 'wiki/get' do
      run Controller::GetMessage
    end

    on 'wiki/rev' do
      run Controller::GetRevision
    end

    on 'wiki/user' do
      run Controller::GetAllUserMessages
    end

    on 'wiki/title' do
      run Controller::GetAllTitleRevisions
    end

    on 'put_error' do
      run Controller::PutError
    end

    on 'signup' do
      on csrf.unsafe? do
        csrf.reset!
        res.status = 403
        res.write('Not authorized')
        halt(res.finish)
      end
      run Controller::SignUp
    end
  end
end
