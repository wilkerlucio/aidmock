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
  module Sanity
    class << self
      def sanitize!
        describe "Aidmock Sanity Checks:" do
          Aidmock.interfaces.each_pair do |klass, interface|
            context klass.to_s do
              (interface.methods + interface.class_methods).each do |method|
                it "have implemented interface for #{method.name}" do
                  Aidmock::Sanity.sanitize_method(interface.klass, method)
                end
              end
            end
          end
        end
      end

      def sanitize_interfaces
        Aidmock.interfaces.each_pair do |klass, interface|
          sanitize_interface(interface)
        end
      end

      def sanitize_interface(interface)
        (interface.methods + interface.class_methods).each do |method|
          sanitize_method(interface.klass, method)
        end
      end

      def sanitize_method(klass, method)
        verify_method_defined(klass, method)
        verify_method_arity(klass, method)
      end

      def verify_method_defined(klass, method)
        return if method.name.instance_of? Regexp
        object = method.class_method? ? klass : klass.allocate

        unless object.respond_to? method.name
          raise "Aidmock Sanity: method '#{method.name}' is not defined for #{klass}"
        end
      end

      def verify_method_arity(klass, method)
        return if method.name.instance_of? Regexp
        object = method.class_method? ? klass : klass.allocate
        defined_method = object.method(method.name)

        unless method.arity == defined_method.arity
          raise "Aidmock Sanity: method '#{method.name}' of #{klass} mismatch interface arity, #{defined_method.arity} for #{method.arity}"
        end
      end

      protected


    end
  end
end
