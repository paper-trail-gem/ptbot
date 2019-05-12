# frozen_string_literal: true

require "comment"

module PTBot
  class TestComment < Minitest::Test
    def test_perform_edit_existing_comment
      repo = "paper-trail-gem/paper_trail"
      issue = Issues::NoTemplate.new(number: 7)
      result = Minitest::Mock.new
      result.expect(:is_a?, true, [Sawyer::Resource])
      result.expect(:to_h, { body: "banana" })
      client = Minitest::Mock.new
      client.expect(:is_a?, true, [Octokit::Client])
      client.expect(
        :issue_comments,
        [
          { id: 6, user: { login: "alice" }},
          { id: 7, user: { login: Comment::BOT_USERNAME }},
          { id: 8, user: { login: "bob" }}
        ],
        [repo, issue.number]
      )
      client.expect(
        :update_comment,
        result,
        [repo, issue.number, /^Thanks for the contribution/]
      )
      log = Logger.new(File.open(File::NULL, "w"))
      Comment.new(client, issue, log, repo).perform
      client.verify
    end
  end
end
