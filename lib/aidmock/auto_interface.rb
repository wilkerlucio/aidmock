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
  module AutoInterface
    class << self
      def define(klass)
        klass.ancestors.each do |k|
          define_interface(k)
        end
      end

      private

      def define_interface(klass)
        return false if Aidmock.has_interface?(klass)

        interface = initialize_interface(klass)

        klass_methods(klass).each do |method|
          args = method_arity_arguments(klass.method(method).arity)
          interface.class_method method, nil, *args
        end

        klass_instance_methods(klass).each do |method|
          args = method_arity_arguments(klass.instance_method(method).arity)
          interface.method method, nil, *args
        end

        Aidmock.interfaces[klass] = interface
      end

      def initialize_interface(klass)
        Interface.new(klass)
      end

      def method_arity_arguments(arity)
        if arity >= 0
          [nil] * arity
        else
          required_arity = arity * -1 - 1
          [nil] * required_arity + [Matchers::SplatArgMatcher.new(nil)]
        end
      end

      def klass_methods(klass)
        (klass.public_methods(false) + klass.protected_methods(false) + klass.private_methods(false)).map { |m| m.to_sym }
      end

      def klass_instance_methods(klass)
        (klass.public_instance_methods(false) + klass.protected_instance_methods(false) + klass.private_instance_methods(false)).map { |m| m.to_sym }
      end
    end
  end
end
