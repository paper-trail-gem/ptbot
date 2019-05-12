# frozen_string_literal: true

require "logger"
require "issues/feature"

module PTBot
  module Issues
    class FeatureTest < Minitest::Test
      def test_omissions
        data = { body: "I am a jerk and I deleted the issue template." }
        omissions = Feature.new(data).omissions
        assert omissions.is_a?(Array)
        assert_equal 1, omissions.length
        omission = omissions.first
        assert_equal :description_of_solution, omission.attribute
        assert_equal "Must use section headers from the template", omission.message
      end
    end
  end
end
