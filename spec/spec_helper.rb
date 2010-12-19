$: << File.expand_path("../../lib", __FILE__)

require 'aidmock'

RSpec::Matchers.define :have_mock_result do |value|
  match do |framework|
    framework.mocks[0].result == value
  end

  failure_message_for_should do |framework|
    "expected the result to be #{value}, got #{framework.mocks[0].result.inspect}"
  end
end
