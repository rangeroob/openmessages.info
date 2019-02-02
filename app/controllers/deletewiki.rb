# frozen_string_literal: true

module Controller
  class DeleteWiki < Cuba; end
  DeleteWiki.define do
    on root,
       param('title'),
       param('username') do |title, username|
      check_authentication_session(username)
      DataTable.where(title: title, username: username).delete
      res.redirect("/wiki/user/#{username}")
    rescue BCrypt::Error
      res.status = 500
    rescue Standard::Error
      res.status = 404
    end
  end
end
