# frozen_string_literal: true

module Controller
  class GetMessage < Cuba; end
  GetMessage.define do
    on ':title' do |title|
      get_wiki(title)
    end
  end
end
