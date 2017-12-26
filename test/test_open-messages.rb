require 'cuba/test'
require 'sequel'
require 'fileutils'
require 'sqlite3'
require_relative '../open-messages.rb'

scope do
  test 'Homepage' do
    get '/'
    assert last_response.ok?
    assert_equal 200, last_response.status
  end
end
scope do
  @invalid_username_password = '<small>* Invalid Username/Password given</small>'
  test 'HomepagePutError' do
    get '/put_error'
    assert last_response.ok?
    assert last_response.body.include?(@invalid_username_password)
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
  @blacklist_password = '<small> * The password provided is blacklisted </small>'
  @used_username = '<small> * Username already in use </small>'
  test 'SignupError' do
    # password is on blacklist
    post '/message/signup', 'username' => 'a', 'password' => 'aaaaaaaaaa'
    assert last_response.body.include?(@blacklist_password)
    # user already exists
    post '/message/signup', 'username' => 'johndoe', 'password' => 'aaaaaaaa'
    assert last_response.body.include?(@used_username)
  end
end
scope do
  test 'GetAllUserMessages' do
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
    delete '/message/delete', 'uuid' => 'a', 'username' => 'abc', 'password' => 'abc'
    assert_equal 500, last_response.status
    # user exists but wrong password
    delete '/message/delete', 'uuid' => 'a', 'username' => 'johndoe', 'password' => 'a'
    assert_equal 404, last_response.status
    # user exists and correct password
    delete '/message/delete', 'uuid' => 'a', 'username' => 'johndoe', 'password' => 'johndoe1'
    assert_equal 200, last_response.status
  end
end
scope do
  test 'PutMessage' do
    put '/message/put', 'username' => 'johndoe', 'password' => 'johndoe1', 'textarea' => '#Hello World'
    follow_redirect!
    assert last_response.body.include?('Hello World')
    assert_equal 200, last_response.status
  end
end
