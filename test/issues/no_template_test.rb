# frozen_string_literal: true

require "logger"
require "issues/no_template"

module PTBot
  module Issues
    class NoTemplateTest < Minitest::Test
      def test_omissions
        data = { body: "I am a jerk and I deleted the issue template." }
        omissions = NoTemplate.new(data).omissions
        assert omissions.is_a?(Array)
        assert_equal 1, omissions.length
        omission = omissions.first
        assert_equal :no_template, omission.attribute
        assert_equal "Issues must follow one of the provided templates", omission.message
      end
    end
  end
end
