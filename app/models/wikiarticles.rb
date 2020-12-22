# frozen_string_literal: true

module Model
  # Wiki Articles Model
  module WikiArticles
    # generates lorem lipsum markdown text using an HTTP API hosted at
    # `https://jaspervdj.be/lorem-markdownum/markdown.txt`

    def generate_markdown
      Net::HTTP.get(URI('https://jaspervdj.be/lorem-markdownum/markdown.txt')).to_s
    end

    # converts titles with a [space] to a [dash]

    def convert_title(title)
      title.downcase.strip.tr(' ', '-').gsub(/[^\w-]/, '')
    end

    # convert titles back with a [dash] to a [space]

    def reconvert_title(title)
      get_title(title).downcase.strip.tr('-', ' ').gsub(/[^\w-]/, ' ')
    end

    # checks whether the title exists

    def check_input_title(title)
      DataTable.where(title: convert_title(title)).get(:title)
    end

    # checks where the title is an gets its value

    def get_title(title)
      DataTable.where(title: title).get(:title)
    end

    # gets the wiki article with a title argument

    def get_wiki(title)
      article = DataTable.where(title: title).get(:textarea)
      @get_title = reconvert_title(title)
      @markdown2html = Kramdown::Document.new(article).to_html
      @html2markdown = Kramdown::Document.new(@markdown2html, input: 'html')
                                         .to_kramdown
    rescue NoMethodError
      res.status = 404
      render('/404')
    else
      render('messages')
    end

    # gets the wiki revision article with a time argument

    def get_revision(time)
      article = RevisionTable.where(edited_on: time).get(:textarea)
      @markdown2html = Kramdown::Document.new(article).to_html
      @html2markdown = Kramdown::Document.new(@markdown2html, input: 'html')
                                         .to_kramdown
    rescue NoMethodError
      res.status = 404
      render('/404')
    else
      render('messages')
    end

    def user_name_exists
      @used_username = '<small>* Username already in use </small>'
      res.status = 500
      render('/signup')
    end

    def password_blacklisted
      @blacklist_password = '<small>*
      The password provided is blacklisted </small>'
      res.status = 500
      render('/signup')
    end
  end
end
