# frozen_string_literal: true

module Controller
  class GetAllWikis < Cuba; end
  GetAllWikis.define do
    on root do
      @user_messages_title = datatable_map_all_articles
      if @user_messages_title.any? || @user_messages_title.empty?
        @array = @user_messages_title.to_a
        @show_user_id = show_user_id
        render('getallwikis')
      end
    end
  end
end
