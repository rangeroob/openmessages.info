# frozen_string_literal: true

module Controller
  class SignUp < Cuba; end
  SignUp.define do
    on get do
      on root do
        @show_user_id = show_user_id
        res.write view('signup')
      end
    end

    on post do
      on root,
         param('username'),
         param('password'),
         param('confirm_password') do |username, password, confirm_password|
        signup_user(username, password, confirm_password)
      end
    end
  end
end
