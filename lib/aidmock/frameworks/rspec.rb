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
              object = proxy.instance_variable_get(:@object)

              proxy.send(:method_doubles).each do |double|
                (double.expectations + double.stubs).each do |stub|
                  method    = stub.sym
                  result    = parse_double_result(stub)
                  arguments = parse_double_arguments(stub)

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

        def parse_double_arguments(double)
          args = double.instance_variable_get(:@args_expectation)
          matchers = args.instance_variable_get(:@matchers)

          (matchers || []).map do |matcher|
            extract_matcher_value(matcher)
          end
        end

        def extract_matcher_value(matcher)
          kind = matcher.class.name[/.+:(.+)$/, 1]
          extractor = find_extractor(kind)
          extractor.call(matcher)
        end

        def register_extractor(name, &block)
          @extractors ||= {}
          @extractors[name] = block
        end

        def find_extractor(name)
          extractor = @extractors[name]
          raise "Can't find extractor for #{name}" unless extractor
          extractor
        end

        def extract_value(value)
          if value.class.name =~ /^RSpec::Mocks::ArgumentMatchers/
            extract_matcher_value(value)
          else
            value
          end
        end
      end

      register_extractor "AnyArgMatcher" do |matcher|
        nil
      end

      register_extractor "BooleanMatcher" do |matcher|
        true
      end

      register_extractor "HashIncludingMatcher" do |matcher|
        expected = matcher.instance_variable_get(:@expected)

        expected.inject({}) do |acc, (key, value)|
          acc[key] = extract_value(value)
          acc
        end
      end

      register_extractor "HashNotIncludingMatcher" do |matcher|
        {}
      end

      register_extractor "DuckTypeMatcher" do |matcher|
        methods = matcher.instance_variable_get(:@methods_to_respond_to)
        object = Object.new
        singleton = class << object; self; end
        singleton.class_eval do
          methods.each do |method|
            define_method method do
              nil
            end
          end
        end

        object
      end

      register_extractor "InstanceOf" do |matcher|
        klass = matcher.instance_variable_get(:@klass)
        klass.allocate
      end

      register_extractor "KindOf" do |matcher|
        klass = matcher.instance_variable_get(:@klass)
        klass.allocate
      end

      register_extractor "EqualityProxy" do |matcher|
        given = matcher.instance_variable_get(:@given)

        extract_value(given)
      end

      register_extractor "RegexpMatcher" do |matcher|
        matcher.instance_variable_get(:@regexp).to_s
      end
    end
  end
end
