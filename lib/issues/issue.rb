# frozen_string_literal: true

require 'omission'

module PTBot
  module Issues
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
      def initialize(data)
        unless data.is_a?(Hash)
          raise TypeError, 'Expected Hash, got ' + @data.class.name
        end
        @data = data
      end

      def complete?
        omissions.empty?
      end

      def number
        @data.fetch(:number)
      end

      def omissions
        @_omissions ||= detect_omissions
      end

      private

      def include?(string)
        @data.fetch(:body).include?(string)
      end
    end
  end
end
