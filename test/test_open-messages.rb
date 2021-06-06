# frozen_string_literal: true

require 'cuba/test'
require 'database_cleaner-sequel'
require_relative '../app/open-messages'

DatabaseCleaner.strategy = :truncation

DatabaseCleaner.cleaning do
  scope do
    test 'create test user' do
      post '/signup', 'username' => 'johndoe', 'password' => 'johndoe1985',
                      'confirm_password' => 'johndoe1985'
    end
  end
  scope do
    test 'Homepage' do
      get '/'
      assert last_response.ok?
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'HomepagePutError' do
      get '/put_error'
      assert last_response.ok?
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'Signup' do
      get 'signup'
      assert last_response.ok?
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'SignupError' do
      # password is on blacklist
      post '/signup', 'username' => 'a', 'password' => 'aaaaaaaaaa',
                      'confirm_password' => 'aaaaaaaaaa'
      assert_equal 500, last_response.status
      # user already exists
      post '/signup', 'username' => 'johndoe', 'password' => 'aaaaaaaa',
                      'confirm_password' => 'aaaaaaaa'
      assert_equal 500, last_response.status
    end
  end
  scope do
    test 'PutWiki' do
      # create a test wiki page
      put '/wiki/put', 'title' => 'test', 'username' => 'johndoe',
                       'password' => 'johndoe1985', 'textarea' => 'Hello World'
      follow_redirect!
      assert last_response.body.include?('Hello World')
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'Authenticate User' do
      # authenticate existing user
      post '/login', 'username' => 'johndoe', 'password' => 'johndoe1985'
      follow_redirect!
      assert last_response.body.include?('johndoe')
      assert_equal 200, last_response.status
      # authenticate nonexisting user
      post '/login', 'username' => 'janedoe', 'password' => 'test'
      assert_equal 401, last_response.status
    end
  end
  scope do
    test 'GetAllUserWikis' do
      # authentcate user johndoe
      post '/login', 'username' => 'johndoe', 'password' => 'johndoe1985'
      # shows wiki pages authored by johndoe if authenticated
      get '/wiki/user/johndoe'
      assert last_response.ok?
      assert_equal 200, last_response.status
      # nonexistent user
      get '/wiki/user/janedoe'
      follow_redirect!
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'GetAllTitleRevisions' do
      # shows wiki page revisions under article title
      get '/wiki/title/test'
      assert last_response.ok?
      assert_equal 200, last_response.status
      get '/wiki/title/doesnotexist'
      assert_equal 404, last_response.status
    end
  end
  scope do
    test 'GetCertainTitleRevision' do
      # show certain page revisions under a point in time
      get "/wiki/rev/#{Time.at(Time.now.to_i).strftime('%Y-%m-%d_%H:%M:%S')}"
      assert_equal 200, last_response.status
      get '/wiki/rev/doesnotexist'
      assert_equal 404, last_response.status
    end
  end
  scope do
    test 'DeleteMessage' do
      # user does not exist redirect to login
      delete '/wiki/delete', 'title' => 'test', 'username' => 'abc',
                             'password' => 'abc'
      follow_redirect!
      assert_equal 302, last_response.status
      # user exists but wrong password redirect to login
      delete '/wiki/delete', 'title' => 'test', 'username' => 'johndoe',
                             'password' => 'a'
      follow_redirect!
      assert_equal 302, last_response.status
      # user exists and correct password
      delete '/wiki/delete', 'title' => 'test', 'username' => 'johndoe',
                             'password' => 'johndoe1985'

      assert_equal 302, last_response.status
    end
  end
end
