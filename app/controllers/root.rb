# frozen_string_literal: true

module Controller
  class Root < Cuba; end
  Root.define do
    on root do
      @show_user_id = show_user_id
      res.write view('home')
    end
  end
end
