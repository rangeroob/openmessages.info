# frozen_string_literal: true

module Controller
  class Login < Cuba; end
  Login.define do
    on get do
      on root do
        res.status = 401 if env['rack.session'][:user_id].nil? == true
        @show_user_id = show_user_id
        render('/login')
      end
    end

    on post do
      on root, param('username'), param('password') do |username, password|
        authenticate(username, password)
      rescue BCrypt::Error
        res.status = 401
        render('/login')
      end
    end
  end
end
