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
      attr_reader :matchers

      def initialize(*matchers)
        @matchers = matchers.map { |matcher| ::Aidmock::Matchers.create(matcher) }
      end

      def match?(object)
        @matchers.any? { |matcher| matcher.match? object }
      end

      def ==(object)
        object.class == AnyMatcher and object.matchers == @matchers
      end
    end

    def any_of(*matchers)
      AnyMatcher.new(*matchers)
    end

    class AnythingMatcher
      def match?(object)
        true
      end

      def ==(object)
        object.class == AnythingMatcher
      end
    end

    def anything
      AnythingMatcher.new
    end

    class DuckTypeMatcher
      attr_reader :methods

      def initialize(*methods)
        @methods = methods
      end

      def match?(object)
        return true if object.nil?
        @methods.all? { |method| object.respond_to? method }
      end

      def ==(object)
        object.class == DuckTypeMatcher and object.methods == @methods
      end
    end

    def respond_to(*methods)
      DuckTypeMatcher.new(*methods)
    end

    class InstanceOfMatcher
      attr_reader :klass

      def initialize(klass)
        @klass = klass
      end

      def match?(object)
        return true if object.nil?
        object.instance_of? @klass
      end

      def ==(object)
        object.class == InstanceOfMatcher and object.klass == @klass
      end
    end

    def instance_of(klass)
      InstanceOfMatcher.new(klass)
    end

    class KindOfMatcher
      attr_reader :klass

      def initialize(klass)
        @klass = klass
      end

      def match?(object)
        return true if object.nil?
        object.kind_of? @klass
      end

      def ==(object)
        object.class == KindOfMatcher and object.klass == @klass
      end
    end

    def kind_of(klass)
      KindOfMatcher.new(klass)
    end

    class HashMatcher
      attr_reader :hash, :strict

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

      def ==(object)
        object.class == HashMatcher and object.hash == @hash and object.strict == @strict
      end
    end

    def hash_including(hash, strict = false)
      HashMatcher.new(hash, strict)
    end

    class NotNilArgMatcher
      attr_reader :matcher

      def initialize(matcher)
        @matcher = ::Aidmock::Matchers.create(matcher)
      end

      def match?(object)
        return false if object.nil?
        @matcher.match? object
      end

      def ==(object)
        object.class == NotNilArgMatcher and object.matcher == @matcher
      end
    end

    def not_nil(value)
      NotNilArgMatcher.new(value)
    end

    alias_method :nn, :not_nil

    class OptionalArgMatcher
      attr_reader :matcher

      def initialize(matcher)
        @matcher = ::Aidmock::Matchers.create(matcher)
      end

      def match?(object)
        @matcher.match? object
      end

      def ==(object)
        object.class == OptionalArgMatcher and object.matcher == @matcher
      end
    end

    def optional(value)
      OptionalArgMatcher.new(value)
    end

    alias_method :o, :optional

    class SplatArgMatcher
      attr_reader :matcher

      def initialize(matcher = nil)
        @matcher = ::Aidmock::Matchers.create(matcher)
      end

      def match?(values)
        values.all? { |value| @matcher.match? value }
      end

      def ==(other)
        other.class == SplatArgMatcher and other.matcher == @matcher
      end
    end

    def splat(value)
      SplatArgMatcher.new(value)
    end

    alias_method :s, :splat
  end
end
