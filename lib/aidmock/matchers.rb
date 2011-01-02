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
  module Matchers
    def self.create(value)
      return AnyMatcher.new(*value) if value.instance_of? ::Array
      return AnythingMatcher.new if value.nil?
      return KindOfMatcher.new(value) if value.instance_of? ::Class
      return DuckTypeMatcher.new(value) if value.instance_of? ::Symbol
      return HashMatcher.new(value) if value.instance_of? ::Hash
      return value if value.respond_to? :match?

      raise "Can't create matcher for #{value.inspect}"
    end

    class AnyMatcher
      def initialize(*matchers)
        @matchers = matchers.map { |matcher| ::Aidmock::Matchers.create(matcher) }
      end

      def match?(object)
        @matchers.any? { |matcher| matcher.match? object }
      end
    end

    class AnythingMatcher
      def match?(object)
        true
      end
    end

    class DuckTypeMatcher
      def initialize(*methods)
        @methods = methods
      end

      def match?(object)
        return true if object.nil?
        @methods.all? { |method| object.respond_to? method }
      end
    end

    class InstanceOfMatcher
      def initialize(klass)
        @klass = klass
      end

      def match?(object)
        return true if object.nil?
        object.instance_of? @klass
      end
    end

    class KindOfMatcher
      def initialize(klass)
        @klass = klass
      end

      def match?(object)
        return true if object.nil?
        object.kind_of? @klass
      end
    end

    class HashMatcher
      def initialize(check_hash, strict = false)
        @hash = {}
        @strict = strict

        check_hash.each do |key, value|
          @hash[key] = ::Aidmock::Matchers.create(value)
        end
      end

      def match?(object)
        return true if object.nil?
        return false unless object.kind_of? Hash

        return false if @strict and (@hash.keys - object.keys).length != 0

        object.each do |key, value|
          return false unless @hash.has_key? key
          return false unless @hash[key].match? value
        end

        true
      end
    end

    class NotNilArgMatcher
      def initialize(matcher)
        @matcher = ::Aidmock::Matchers.create(matcher)
      end

      def match?(object)
        return false if object.nil?
        @matcher.match? object
      end
    end

    class OptionalArgMatcher
      def initialize(matcher)
        @matcher = ::Aidmock::Matchers.create(matcher)
      end

      def match?(object)
        @matcher.match? object
      end
    end

    class SplatArgMatcher
      def initialize(matcher = nil)
        @matcher = ::Aidmock::Matchers.create(matcher)
      end

      def match?(values)
        values.all? { |value| @matcher.match? value }
      end
    end
  end
end
