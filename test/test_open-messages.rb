# frozen_string_literal: true

require 'cuba/test'
require 'database_cleaner'
require 'sequel'
require 'fileutils'
require 'sqlite3'
require_relative '../open-messages.rb'

DatabaseCleaner.strategy = :truncation

DatabaseCleaner.cleaning do
  scope do 
    test 'create test user' do
      post '/message/signup', 'username' => 'johndoe', 'password' => 'johndoe1985',
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
      post '/message/signup', 'username' => 'a', 'password' => 'aaaaaaaaaa',
                              'confirm_password' => 'aaaaaaaaaa'
      assert_equal 500, last_response.status
      # user already exists
      post '/message/signup', 'username' => 'johndoe', 'password' => 'aaaaaaaa',
                              'confirm_password' => 'aaaaaaaa'
      assert_equal 500, last_response.status
    end
  end
  scope do
    test 'PutMessage' do
      #create a test page
      put '/message/put', 'title' => 'test', 'username' => 'johndoe', 'password' => 'johndoe1985', 'textarea' => '#Hello World'
      follow_redirect!
      assert last_response.body.include?('Hello World')
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'GetAllUserMessages' do
      # shows test page link under user
      get '/message/user/johndoe'
      assert last_response.ok?
      assert_equal 200, last_response.status
      get '/message/user/janedoe'
      follow_redirect!
      assert_equal 200, last_response.status
    end
  end
  scope do
    test 'DeleteMessage' do
      # user does not exist
      delete '/message/delete', 'title' => 'test', 'username' => 'abc', 'password' => 'abc'
      assert_equal 500, last_response.status
      # user exists but wrong password
      delete '/message/delete', 'title' => 'test', 'username' => 'johndoe', 'password' => 'a'
      assert_equal 404, last_response.status
      # user exists and correct password
      delete '/message/delete', 'title' => 'test', 'username' => 'johndoe', 'password' => 'johndoe1985'
      assert_equal 200, last_response.status
    end
  end
end
