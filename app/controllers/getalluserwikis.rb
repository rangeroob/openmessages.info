# frozen_string_literal: true

module Controller
  class GetAllUserMessages < Cuba; end
  GetAllUserMessages.define do
    on root do
      res.redirect('/login')
    end
    on ':username' do |username|
      check_authentication_session(username)
      @user_messages_title = datatable_where_username_map_articles(username)
      if @user_messages_title.any? || @user_messages_title.empty?
        @array = @user_messages_title.to_a
        @author = username.to_s
        @show_user_id = show_user_id
        render('getalluserwikis')
      end
    end
  end
end
