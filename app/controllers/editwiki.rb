# frozen_string_literal: true

module Controller
  class EditWiki < Cuba; end
  EditWiki.define do
    on root,
       param('title'),
       param('textarea') do |title, textarea|
      if show_user_id.nil? || DataTable.where(username:!show_user_id,title:title)
        res.redirect('/login')
      else
        DB.transaction do
          datatable_where_converted_title(title)
          editwiki_revision_insert_transcation(title, textarea)
          datatable_update_editedon_textarea_transaction(title, textarea)
        end
        res.redirect("/wiki/get/#{convert_title(title)}")
      end
    rescue BCrypt::Errors::InvalidHash
      res.redirect('/put_error')
    end
  end
end
