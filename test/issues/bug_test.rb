# frozen_string_literal: true

require "logger"
require "issues/bug"

module PTBot
  module Issues
    class BugTest < Minitest::Test
      def test_omissions
        data = { body: "I am a jerk and I deleted the issue template." }
        omissions = Bug.new(data).omissions
        assert omissions.is_a?(Array)
        assert_equal 1, omissions.length
        omission = omissions.first
        assert_equal :reproduction_script, omission.attribute
        assert_equal "Reproduction script must use bundler/inline", omission.message
      end
    end
  end
end
