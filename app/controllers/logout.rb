# frozen_string_literal: true

module Controller
  class Logout < Cuba; end
  Logout.define do
    on get do
      on root do
        user_logout
        res.redirect('/')
      end
    end
  end
end
