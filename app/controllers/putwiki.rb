# frozen_string_literal: true

module Controller
  class PutWiki < Cuba; end
  PutWiki.define do
    on root,
       param('username'),
       param('password'),
       param('title'),
       param('textarea') do |username, password, title, textarea|
      generate_id = SecureRandom.uuid
      password = check_password(username, password)
      check_title = check_input_title(title)
      if (password == true) && (check_title != convert_title(title))
        DB.transaction do
          putwiki_datatable_transaction(generate_id, username, title, textarea)
          putwiki_revision_transcation(generate_id, username, title, textarea)
        end
        res.redirect("/wiki/get/#{convert_title(title)}")
      elsif (password == false) || (check_title == convert_title(title))
        res.redirect('/put_error')
      end
    rescue BCrypt::Errors::InvalidHash
      res.status = 500
      res.redirect('/put_error')
    end
  end
end
