# frozen_string_literal: true

require 'octokit'
require 'issues/issue'

module PTBot
  # Add or edit existing comment.
  #
  # Example of `add_coment` return value:
  #
  # ```
  # {
  #   :url=>"https://api.github.com/repos/jaredbeck/testing-gh-api/issues/comments/487444777",
  #   ...
  #   :id=>487444777,
  #   ...
  #   :user=>{:login=>"paper-trail-bot", ..},
  #   :created_at=>2019-04-29 03:46:00 UTC,
  #   :updated_at=>2019-04-29 03:46:00 UTC,
  #   :author_association=>"NONE",
  #   :body=>"noooooooope"
  # }
  # ```
  class Comment
    # Bot should skip established conversations, for two reasons. First, if a
    # bunch of humans are already talking, nobody needs a bot (sorry, bot).
    # Second, it's a nice way to prevent the bot from going wild and spamming
    # an issue (it'll stop when it's made this many comments [not great, but
    # better than no safeguard]).
    ESTABLISHED_CONVERSATION = 3 # Number of comments (original post not counted)

    INTRO = "Thanks for the contribution! It looks like there's something missing though:"
    INSTRUCTIONS = <<~EOS
      Due to limited volunteer time, please ask usage questions on [StackOverflow][2].
      
      Bug reports are required to use our [bug report template][3]. See also 
      our [contributing guide][1].

      [1]: https://github.com/paper-trail-gem/paper_trail/blob/master/.github/CONTRIBUTING.md
      [2]: https://stackoverflow.com/tags/paper-trail-gem
      [3]: https://github.com/paper-trail-gem/paper_trail/blob/master/.github/ISSUE_TEMPLATE/bug_report.md
    EOS
    PARAGRAPH_DELIMITER = "\n\n"
    BOT_USERNAME = "paper-trail-bot"

    def initialize(client, issue, log, repo)
      raise TypeError unless client.is_a?(Octokit::Client)
      @client = client
      raise TypeError unless issue.is_a?(Issues::Issue)
      @issue = issue
      raise TypeError unless log.is_a?(Logger)
      @log = log
      raise TypeError unless repo.is_a?(String)
      @repo = repo
    end

    def perform
      log_debug format("has %d comments", comments.length)
      if comments.length >= ESTABLISHED_CONVERSATION
        log_debug(
          format(
            'Skipping issue with %d or more comments',
            ESTABLISHED_CONVERSATION
          )
        )
        return
      end
      comment_number = id_of_my_first_comment
      log_debug format("id of my first comment: %d", comment_number.inspect)
      comment_number.nil? ? add : edit(comment_number)
    end

    private

    def add
      nil # temporary no-op while troubleshooting spam issue
      # log_debug 'Adding new comment'
      # result = @client.add_comment(
      #   @repo,
      #   issue_number,
      #   body(@issue.omissions)
      # )
      # if is_a_comment?(result)
      #   log_debug 'Comment added'
      # else
      #   error = format('Failed to add comment: result: %s', result.inspect)
      #   @log.error(error)
      #   raise error
      # end
    end

    # Given array of omissions, return markdown string.
    def body(omissions)
      [
        INTRO,
        markdown_list_of_omissions(omissions),
        INSTRUCTIONS
      ].join(PARAGRAPH_DELIMITER)
    end

    # Extant comments
    def comments
      @_comments ||= begin
        log_debug "Getting comments"
        @client.issue_comments(@repo, issue_number)
      end
    end

    def edit(comment_number)
      log_debug format('Editing existing comment %s %d', @repo, comment_number)
      new_body = body(@issue.omissions)
      result = @client.update_comment(@repo, comment_number, new_body)
      if is_a_comment?(result)
        log_debug 'Comment updated'
      else
        error = format('Failed to update comment: result: %s', result.inspect)
        @log.error(error)
        raise error
      end
    end

    def id_of_my_first_comment
      log_debug "Did I already comment?"
      my_comment = comments.find { |resource|
        login = resource.to_h.fetch(:user).fetch(:login)
        log_debug(format("%s == %s: %s", login, BOT_USERNAME, (login == BOT_USERNAME).inspect))
        login == BOT_USERNAME
      }
      log_debug format("my_comment: %s", my_comment.inspect)
      my_comment.nil? ? nil : my_comment.fetch(:id)
    end

    def is_a_comment?(obj)
      obj.is_a?(Sawyer::Resource) && obj.to_h.key?(:body)
    end

    def issue_number
      @issue.number
    end

    def log_debug(message)
      @log.debug format("issue %d: %s", issue_number, message)
    end

    def markdown_list_of_omissions(omissions)
      omissions.map { |omission|
        format('- %s: %s', omission.attribute, omission.message)
      }.join("\n")
    end
  end
end
