# frozen_string_literal: true

module Controller
  class GetRevision < Cuba; end
  GetRevision.define do
    on ':time' do |time|
      @show_user_id = show_user_id
      get_revision(time)
    end
  end
end
