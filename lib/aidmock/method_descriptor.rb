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
  class MethodDescriptor
    attr_accessor :name, :type, :arguments, :class_method
    alias :class_method? :class_method

    def initialize(name, type, *arguments)
      @name = name
      @type = ::Aidmock::Matchers.create(type)
      @arguments = arguments.map { |arg| ::Aidmock::Matchers.create(arg) }
      @class_method = false
    end

    def verify(double)
      verify_arguments(double)
      verify_return(double)
    end

    def verify_arguments(double)
      arguments = double.arguments
      check_method_arity!(double)
      current_matcher = 0

      while arguments.length > 0
        matcher = @arguments[current_matcher]

        if matcher.instance_of? ::Aidmock::Matchers::SplatArgMatcher
          arg = arguments
          arguments = []
        else
          arg = arguments.shift
        end

        unless matcher.match?(arg)
          raise Aidmock::MethodInterfaceArgumentsNotMatchError.new("argument value #{arg.inspect} doesn't match with #{matcher.inspect}")
        end

        current_matcher += 1
      end
    end

    def verify_return(double)
      double.result.each do |value|
        unless @type.match?(value)
          raise Aidmock::MethodInterfaceReturnNotMatchError.new("Return value #{value.inspect} doesn't match with #{@type.inspect}")
        end
      end
    end

    def arity
      @arity ||= begin
        arity = 0

        @arguments.each do |arg|
          arity += 1

          if optional_arg? arg
            arity *= -1
            return arity
          end
        end

        arity
      end
    end

    def required_arity
      @required_arity = begin
        required = arity

        if required < 0
          required *= -1
          required -= 1
        end

        required
      end
    end

    def max_number_of_arguments
      return nil if has_a_splat?

      @arguments.length
    end

    protected

    def check_method_arity!(double)
      length = double.arguments.length
      # in case of positive arity (fixed number of arguments)
      if arity >= 0
        if length != arity
          raise Aidmock::MethodInterfaceArgumentsNotMatchError.new("error on mock method #{double.method.inspect}, expected #{arity} arguments, #{length} sent")
        end
      # on negative arity (variable number of arguments)
      else
        if length < required_arity
          raise Aidmock::MethodInterfaceArgumentsNotMatchError.new("error on mock method #{double.method.inspect}, expected at least #{required_arity}, #{length} sent")
        end

        if max = max_number_of_arguments
          if length > max
            raise Aidmock::MethodInterfaceArgumentsNotMatchError.new("error on mock method #{double.method.inspect}, expected at most #{max}, #{length} sent")
          end
        end
      end
    end

    def has_a_splat?
      @arguments.last.instance_of? ::Aidmock::Matchers::SplatArgMatcher
    end

    def optional_arg?(arg)
      arg.instance_of? Matchers::OptionalArgMatcher or arg.instance_of? Matchers::SplatArgMatcher
    end
  end
end
