# frozen_string_literal: true

module Controller
  class GetAllTitleRevisions < Cuba; end
  GetAllTitleRevisions.define do
    on ':title' do |title|
      @title_revisions = RevisionTable.where(title: convert_title(title).to_s)
                                      .select_map(:edited_on)
      if @title_revisions.any?
        @array = @title_revisions.to_a
        res.write view('getalltitlerevisions')
      elsif @title_revisions.empty?
        res.status = 404
        res.write view('/404')
      end
    end
  end
end
