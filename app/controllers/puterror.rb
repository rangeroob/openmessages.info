# frozen_string_literal: true

module Controller
  class PutError < Cuba; end
  PutError.define do
    on root do
      @invalid_username_password = '<small>* Invalid Username/Password given</small>'
      render('home')
    end
  end
end
