# frozen_string_literal: true

require 'byebug'
require 'dotenv'
require 'logger'
require 'octokit'

$LOAD_PATH << File.join(File.expand_path(__dir__), 'lib')
require 'comment'
require 'issues/factory'

module PTBot
  # https://developer.github.com/v3/#rate-limiting
  class Bot
    # Limit number of issues parsed as a precaution (new issues considered
    # first). We may increase this later, but we don't want a bot running wild.
    MAX_ISSUES = 10

    REPO_NAME_PATTERN = /\w+\/\w+/.freeze

    def initialize
      @github_api_token = ENV.fetch("GITHUB_API_TOKEN")
      @log = Logger.new(STDOUT)
      @repo = ENV.fetch("REPO_NAME")
      unless REPO_NAME_PATTERN.match?(@repo)
        raise TypeError, 'Invalid repo name: ' + @repo
      end
    end

    def run
      log_current_user
      incomplete_issues.each do |issue|
        @log.debug 'comment on incomplete issue'
        Comment.new(client, issue, @log, @repo).perform
      end
      @log.debug "Done. Bot out."
    end

    private

    def client
      @_client ||= Octokit::Client.new(
        access_token: @github_api_token,

        # When the bot looks to see if it has already commented on an issue,
        # it's important that it looks at every existing comment.
        # https://github.com/octokit/octokit.rb#auto-pagination
        auto_paginate: true
      )
    end

    def client_user_login
      client.user.to_h.fetch(:login)
    end

    def incomplete_issues
      open_issues.reject(&:complete?)
    end

    # Open issues, in descending order of creation date, up to `MAX_ISSUES`.
    def open_issues
      @log.debug "Listing issues .."
      issues_and_prs = client.issues(
        @repo,
        direction: 'desc',
        sort: 'created',
        state: 'open'
      )
      @log.debug format("%d open issues and PRs", issues_and_prs.length)
      issues = issues_and_prs.reject { |i| i.key?(:pull_request) }
      @log.debug format("%d open issues (max %d)", issues.length, MAX_ISSUES)
      issues.to_a.take(MAX_ISSUES).map { |resource| # Sawyer::Resource
        Issues::Factory.new.build(resource.to_h)
      }
    end

    def log_current_user
      @log.debug "Authenticated as #{client_user_login}"
    end
  end
end

Dotenv.load
PTBot::Bot.new.run
