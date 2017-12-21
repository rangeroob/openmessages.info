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
    post '/message/signup', 'username' => 'a', 'password' => 'aaaaaaaaaa'
    assert last_response.body.include?(@blacklist_password)
    post '/message/signup', 'username' => 'johndoe', 'password' => 'aaaaaaaa'
    assert last_response.body.include?(@used_username)
  end
end
scope do
  test 'GetAllUserMessages' do
    get '/message/user/johndoe'
    assert last_response.ok?
    assert_equal 200, last_response.status
  end
end
scope do
  test 'DeleteMessage' do
    delete'/message/delete', 'uuid' => 'x', 'username' => 'abc', 'password' => 'abc'
    assert_equal 500, last_response.status
    delete '/message/delete', 'uuid' => 'a', 'username' => 'johndoe', 'password' => 'jonhdoe1'
    assert_equal 200, last_response.status
  end
end
