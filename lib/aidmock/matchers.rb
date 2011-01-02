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
    def self.factory(value)

    end

    class AnyMatcher
      def initialize(*matchers)
        @matchers = matchers.map { |matcher| ::AidMock::Matchers.factory(matcher) }
      end

      def match?(object)
        @matchers.any { |matcher| matcher.match? object }
      end
    end

    class DuckTypeMatcher
      def initialize(*methods)
        @methods = methods
      end

      def match?(object)
        @methods.all { |method| object.respond_to? method }
      end
    end

    class InstanceOfMatcher
      def initialize(klass)
        @klass = klass
      end

      def match?(object)
        object.instance_of? @klass
      end
    end

    class KindOfMatcher
      def initialize(klass)
        @klass = klass
      end

      def match?(object)
        object.kind_of? @klass
      end
    end
  end
end
