# frozen_string_literal: true

module Controller
  class Root < Cuba; end
  Root.define do
    on root do
      @show_user_id = show_user_id
      render('home')
    end
  end
end
