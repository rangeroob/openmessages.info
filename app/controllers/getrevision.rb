# frozen_string_literal: true

module Controller
  class GetRevision < Cuba; end
  GetRevision.define do
    on ':time' do |time|
      get_revision(time)
    end
  end
end
