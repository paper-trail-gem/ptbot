# frozen_string_literal: true

require "omission"

module PTBot
  class TestOmission < Minitest::Test
    def test_constructor
      om = Omission.new(:kiwi, "is gross")
      assert_equal om.attribute, :kiwi
      assert_equal om.message, "is gross"
    end
  end
end
