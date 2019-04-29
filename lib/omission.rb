# frozen_string_literal: true

module PTBot
  # Something missing from an issue.
  class Omission
    attr_reader :attribute, :message

    def initialize(attribute, message)
      raise TypeError unless attribute.is_a?(Symbol)
      @attribute = attribute
      raise TypeError unless message.is_a?(String)
      @message = message
    end
  end
end
