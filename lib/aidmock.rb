module Aidmock
  class << self
    def interface(klass, &block)
      interfaces[klass] = create_or_update_interface(klass, &block)
    end

    def stub(klass, stubs = {})
    end

    def verify
      framework.mocks.each do |mock|
        interface = interfaces[mock.klass]

        if interface
          interface.verify(mock)
        else
          # TODO: warn no interface defined
        end
      end
    end

    protected

    def interfaces
      @interfaces ||= {}
    end

    def framework
      ::Aidmock::Frameworks::RSpec
    end

    def create_or_update_interface(klass, &block)
      interface = interfaces[klass] || Interface.new(klass)
      interface.instance_eval &block
      interface
    end
  end

  class Interface
    def initialize(klass)
      @klass = klass
      @methods = []
    end

    def method(name, type, *arguments)
      @methods << MethodDescriptor.new(name, type, *arguments)
    end

    def verify(mock)
      method = find_method(mock)

      if method
        # TODO: check arguments and return value
      else
        raise %Q{Aidmock: method "#{mock.method}" was not defined for "#{mock.klass}" interface}
      end
    end

    def find_method(mock)
      @methods.find do |method|
        method.name == mock.method
      end
    end
  end

  class ArgumentList

  end

  class MethodDescriptor
    attr_accessor :name, :type, :arguments

    def initialize(name, type, *arguments)
      @name = name
      @type = type
      @arguments = arguments
    end
  end

  class VoidClass < BasicObject
    def method_missing(name, *args, &block)
      nil
    end
  end

  module Frameworks
    MockDescriptor = Struct.new(:klass, :method, :result, :arguments)

    module RSpec
      class << self
        def mocks
          [].tap do |mocks|
            ::RSpec::Mocks.space.send(:mocks).each do |moc|
              proxy  = moc.send(:__mock_proxy)
              object = proxy.instance_variable_get(:@object).class

              proxy.send(:method_doubles).each do |double|
                (double.expectations + double.stubs).each do |stub|
                  method    = stub.sym
                  result    = parse_double_result(stub)
                  arguments = ArgumentList.new

                  mocks << MockDescriptor.new(object, method, result, arguments)
                end
              end
            end
          end
        end

        protected

        def parse_double_result(double)
          block = double.instance_variable_get(:@return_block)

          if block
            result = call_result_block(block)
            double.instance_variable_get(:@consecutive) ? result : [result]
          else
            []
          end
        end

        def call_result_block(block)
          arity = block.arity
          params = (1..arity).map { VoidClass.new }

          block.call(*params)
        end
      end
    end
  end
end
