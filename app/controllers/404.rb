# frozen_string_literal: true

module Controller
  class FourOFour < Cuba; end
  FourOFour.define do
    on root do
      res.write partial('404')
    end
  end
end
