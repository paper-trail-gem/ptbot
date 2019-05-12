# frozen_string_literal: true

require "logger"
require "issues/factory"

module PTBot
  module Issues
    class FactoryTest < Minitest::Test
      def test_build_no_template
        data = { body: "I am a jerk and I deleted the issue template." }
        issue = Factory.new.build(data)
        assert_equal NoTemplate, issue.class
      end

      def test_build_bug
        data = { body: Factory::REPRODUCTION_SCRIPT }
        issue = Factory.new.build(data)
        assert_equal Bug, issue.class
      end

      def test_build_feature
        data = { body: Factory::FEATURE_COMMITMENT }
        issue = Factory.new.build(data)
        assert_equal Feature, issue.class
      end
    end
  end
end
