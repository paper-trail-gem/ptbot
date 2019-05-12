# frozen_string_literal: true

require "logger"
require "issue"

module PTBot
  class TestIssue < Minitest::Test
    def test_constructor
      data = {}
      repo = "paper-trail-gem/paper_trail"
      log = Logger.new(STDOUT)
      issue = Issue.new(data, repo, log)
      assert_equal issue.repo, repo
    end

    def test_number
      data = { number: 7 }
      repo = "paper-trail-gem/paper_trail"
      log = Logger.new(STDOUT)
      issue = Issue.new(data, repo, log)
      assert_equal issue.number, 7
    end

    def test_omissions
      data = { body: "I am a jerk and I deleted the issue template." }
      repo = "paper-trail-gem/paper_trail"
      log = Logger.new(STDOUT)
      omissions = Issue.new(data, repo, log).omissions
      assert omissions.is_a?(Array)
      assert_equal omissions.length, 1
      omission = omissions.first
      assert_equal omission.attribute, :reproduction_script
      assert_equal omission.message, 'Bug reports require a reproduction script'
    end
  end
end
