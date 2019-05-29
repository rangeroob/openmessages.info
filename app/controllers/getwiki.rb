# frozen_string_literal: true

module Controller
  class GetMessage < Cuba; end
  GetMessage.define do
    on ':title' do |title|
      @show_user_id = show_user_id
      get_wiki(title)
    end
  end
end
