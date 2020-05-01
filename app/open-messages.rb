# frozen_string_literal: true

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require_relative 'models/base_model'
require_relative 'controllers/404'
require_relative 'controllers/deletewiki'
require_relative 'controllers/editwiki'
require_relative 'controllers/getallwikis'
require_relative 'controllers/getalluserwikis'
require_relative 'controllers/getrevision'
require_relative 'controllers/gettalltitlerevisions'
require_relative 'controllers/getwiki'
require_relative 'controllers/github'
require_relative 'controllers/putwiki'
require_relative 'controllers/puterror'
require_relative 'controllers/root'
require_relative 'controllers/login'
require_relative 'controllers/logout'
require_relative 'controllers/signup'

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
    on 'auth/:provider' do |provider|
      run Controller::Auth::Github if provider == 'github'
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

    on 'auth/:provider/callback' do |provider|
      run Controller::Auth::Github if provider == 'github'
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

    on 'wiki/articles' do
      run Controller::GetAllWikis
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
