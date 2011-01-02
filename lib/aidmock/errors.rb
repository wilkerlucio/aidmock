module Aidmock
  class Error < ::StandardError; end
  class InvalidMockError < Error; end
  class MethodInterfaceNotDefinedError < InvalidMockError; end
  class MethodInterfaceReturnNotMatchError < InvalidMockError; end
  class MethodInterfaceArgumentsNotMatchError < InvalidMockError; end
end
