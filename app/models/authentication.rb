# frozen_string_literal: true

module Model
  # Authentication Model
  module Authentication
    # generates user session labeled as
    # `:user_id` which the value is equal to
    # the username given as an arguement

    def generate_user_session(username)
      env['rack.session'][:user_id] = username
    end

    # authenticates username with
    # two arguements given one being the username
    # and two the password of the account

    def authenticate(username, password)
      check_password = BCrypt::Password.new(
        UserTable.where(username: username).get(:password)
      ).is_password?(password)
      if check_password == true
        generate_user_session(username)
        res.redirect("/wiki/user/#{username}")
      elsif check_password == false
        res.status = 401
        res.write view('/login')
      end
    end

    # checks the session against the username given and if the differ
    # redirects to the login page

    def check_authentication_session(username)
      res.redirect('/login') if env['rack.session'][:user_id] != username
    end

    # checks to see where the username is and if the password assoicated
    # with username is the correct password

    def check_password(username, password)
      BCrypt::Password.new(
        UserTable.where(username: username).get(:password)
      ).is_password?(password)
    end

    # shows the value of the `rack.session` `:user_id` key

    def show_user_id
      env['rack.session'][:user_id]
    end

    # checkes to see if the session key `:user_id` is nil?
    # and redirects to the login page if `true`

    def authenticated?
      res.redirect('/login') if env['rack.session'][:user_id].nil?
    end

    # deletes the `:user_id` session key and
    # destroys the session altogether

    def user_logout
      env['rack.session'].delete(:user_id)
      env['rack.session'].destroy
    end
  end
end
