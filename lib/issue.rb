# frozen_string_literal: true

require 'omission'

module PTBot
  # Example:
  #
  # {
  #   :url=>"https://api.github.com/repos/../issues/578",
  #   ..
  #   :id=>279888771,
  #   :node_id=>"MDU6SXNzdWUyNzk4ODg3NzE=",
  #   :number=>578,
  #   :title=>"Fix it!",
  #   :user=>{:login=>"tiegz", :id=>5054, ..},
  #   :labels=>[{:id=>771598293, ..}],
  #   :state=>"open",
  #   :locked=>false,
  #   ..
  #   :body=>"I am entitled to free labor"
  # }
  class Issue
    REPO_NAME_PATTERN = /\w+\/\w+/.freeze
    REPRODUCTION_SCRIPT = 'This bug can be reproduced with the script I provide below'

    attr_reader :repo

    def initialize(data, repo, log)
      unless data.is_a?(Hash)
        raise TypeError, 'Expected Hash, got ' + @data.class.name
      end
      @data = data
      unless repo.is_a?(String) && REPO_NAME_PATTERN.match?(repo)
        raise TypeError, 'Invalid repo name: ' + repo
      end
      @repo = repo
      @log = log
    end

    def complete?
      omissions.empty?
    end

    def number
      @data.fetch(:number)
    end

    def omissions
      @_omissions ||= [
        omission_of_reproduction_script
        # highly likely we'll check for other omissions in the future
      ].compact
    end

    private

    def omission_of_reproduction_script
      unless @data.fetch(:body).include?(REPRODUCTION_SCRIPT)
        Omission.new(
          :reproduction_script,
          'Bug reports require a reproduction script'
        )
      end
    end
  end
end
