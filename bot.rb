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
      issues = client.issues(@repo, state: 'open')
      @log.debug format("%d open issues", issues.length)
      issues.to_a.map { |resource| # Sawyer::Resource
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
