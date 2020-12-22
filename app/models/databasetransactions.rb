# frozen_string_literal: true

module Model
  # Database Transaction Model
  module DatabaseTransactions
    # Generates time in epoch format then converts it to
    # Year-month-day_Hour-Minute-Second time format.

    def generate_time
      Time.at(Time.now.to_i).strftime('%Y-%m-%d_%H:%M:%S')
    end
    # Puts wiki article into the `data` table
    # takes arguments of the generate_id, username,
    # title, and textarea

    def putwiki_datatable_transaction(generate_id, username, title, textarea)
      DataTable.insert(uuid: generate_id.to_s, username: username.to_s,
                       title: convert_title(title).to_s,
                       created_on: generate_time, edited_on: generate_time,
                       textarea: textarea.to_s)
    end

    # Puts wiki article into the `revision` table
    # takes arguments of the generate_id, username,
    # title, and textarea

    def putwiki_revision_transcation(generate_id, username, title, textarea)
      RevisionTable.insert(uuid: generate_id.to_s, username: username.to_s,
                           title: convert_title(title).to_s,
                           created_on: generate_time, edited_on: generate_time,
                           textarea: textarea.to_s)
    end

    # Updates wiki article into the `revision` table
    # takes arguments of the title and textarea

    def editwiki_revision_insert_transcation(title, textarea)
      RevisionTable.insert(uuid:
        DataTable.where(title: convert_title(title).to_s).select(:uuid),
                           title: convert_title(title).to_s,
                           textarea: textarea, edited_on: generate_time,
                           created_on:
                           datatable_get_createdon_transcation(title),
                           username:
                           datatable_select_username_transcation(title))
    end

    # generates an article once the user signs up

    def datatable_generate_first_article
      generate_id = SecureRandom.uuid
      freeze_generate_markdown = "#Welcome to OpenMessages.info\n" + generate_markdown
      DataTable.insert(uuid: generate_id.to_s, username: show_user_id.to_s,
                       title: generate_id.to_s,
                       created_on: generate_time, edited_on: generate_time,
                       textarea: freeze_generate_markdown)
      RevisionTable.insert(uuid: generate_id.to_s, username: show_user_id.to_s,
                           title: generate_id.to_s,
                           created_on: generate_time, edited_on: generate_time,
                           textarea: freeze_generate_markdown)
      res.redirect("/wiki/user/#{show_user_id}")
    end

    def datatable_get_createdon_transcation(title)
      DataTable.where(title:
        convert_title(title).to_s).get(:created_on)
    end

    def datatable_select_username_transcation(title)
      DataTable.where(title:
        convert_title(title).to_s).select(:username)
    end

    def datatable_where_username_map_articles(username)
      DataTable.where(
        username: username
      ).select_map(:title)
    end

    def datatable_map_all_articles
      DataTable.select_map(:title)
    end

    def datatable_where_converted_title(title)
      DataTable.where(title:
        convert_title(title).to_s)
    end

    def datatable_update_editedon_textarea_transaction(title, textarea)
      DataTable.where(title: convert_title(title).to_s)
               .update(edited_on: generate_time, textarea: textarea)
    end

    def insert_user_transaction(username, password)
      bcrypted_password = BCrypt::Password.create(password)
      UserTable.insert(username: username, password: bcrypted_password)
    end
  end
end
