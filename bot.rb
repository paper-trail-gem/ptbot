# frozen_string_literal: true

require 'byebug'
require 'dotenv'
require 'logger'
require 'octokit'

$LOAD_PATH << File.join(File.expand_path(__dir__), 'lib')
require 'comment'
require 'issue'

module PTBot
  # https://developer.github.com/v3/#rate-limiting
  class Bot
    def initialize
      @github_api_token = ENV.fetch("GITHUB_API_TOKEN")
      @log = Logger.new(STDOUT)
      @repo = ENV.fetch("REPO_NAME")
    end

    def run
      log_current_user
      incomplete_issues.each do |issue|
        @log.debug 'comment on incomplete issue'
        Comment.new(client, issue, @log).perform
      end
      @log.debug "Done. Bot out."
    end

    private

    def client
      @_client ||= Octokit::Client.new(access_token: @github_api_token)
    end

    def client_user_login
      client.user.to_h.fetch(:login)
    end

    def incomplete_issues
      open_issues.reject(&:complete?)
    end

    def open_issues
      @log.debug "Listing issues .."
      issues = client.issues(REPO, state: 'open')
      @log.debug format("%d open issues", issues.length)
      issues.to_a.map { |resource| # Sawyer::Resource
        Issue.new(resource.to_h, REPO, @log)
      }
    end

    def log_current_user
      @log.debug "Authenticated as #{client_user_login}"
    end
  end
end

Dotenv.load
PTBot::Bot.new.run
