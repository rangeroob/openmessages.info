# frozen_string_literal: true
Sequel.migration do
  change do
    create_table(:data, ignore_index_errors: true) do
      primary_key :id
      String :uuid, size: 255
      String :username, size: 255
      String :title, size: 255
      String :created_on, size: 255
      String :edited_on, size: 255
      File :textarea

      index %i[uuid title username]
    end

    create_table(:datarevisions) do
      String :uuid, size: 255
      String :username, size: 255
      String :title, size: 255
      String :created_on, size: 255
      String :edited_on, size: 255
      File :textarea
    end

    create_table(:user) do
      String :username, size: 255
      String :password, size: 255
    end
  end
end
