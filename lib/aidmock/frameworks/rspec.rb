# Copyright (c) 2011 Wilker Lúcio
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Aidmock
  module Frameworks
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
