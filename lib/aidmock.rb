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

require 'aidmock/errors'
require 'aidmock/basic_object' unless Kernel.const_defined? :BasicObject

module Aidmock
  autoload :Interface, 'aidmock/interface'
  autoload :MethodDescriptor, 'aidmock/method_descriptor'
  autoload :VoidClass, 'aidmock/void_class'
  autoload :Frameworks, 'aidmock/frameworks'
  autoload :Matchers, 'aidmock/matchers'
  autoload :Sanity, 'aidmock/sanity'

  class << self
    attr_accessor :warn_undefined_interface
    alias :warn_undefined_interface? :warn_undefined_interface

    def interface(klass, &block)
      interfaces[klass] = create_or_update_interface(klass, &block)
    end

    def stub(klass, stubs = {})
    end

    def verify
      framework.mocks.each do |mock|
        verify_double(mock)
      end
    end

    def interfaces
      @interfaces ||= {}
    end

    def framework
      ::Aidmock::Frameworks::RSpec
    end

    def setup
      framework.extend_doubles
    end

    protected

    def verify_double(double)
      klass = extract_class(double.object)
      chain = chain_for(klass)

      if chain.length > 0
        verify_double_on_chain(double, chain)
      else
        puts "Aidmock Warning: unsafe mocking on class #{klass}, please interface it" if warn_undefined_interface?
      end
    end

    def verify_double_on_chain(double, chain)
      method = find_method_on_chain(double, chain)

      if method
        method.verify(double)
      else
        raise MethodInterfaceNotDefinedError.new(%Q{Aidmock: method "#{double.method}" was not defined for "#{extract_class(double.object)}" interface})
      end
    end

    def find_method_on_chain(double, chain)
      chain.each do |interface|
        method = interface.find_method(double)
        return method if method
      end

      nil
    end

    def chain_for(klass)
      klass.ancestors.select { |k| interfaces[k] }.map { |k| interfaces[k] }
    end

    def extract_class(object)
      return object.aidmock_class if object.respond_to? :aidmock_class and object.aidmock_class != nil
      object.instance_of?(Class) ? object : object.class
    end

    def create_or_update_interface(klass, &block)
      interface = interfaces[klass] || Interface.new(klass)
      interface.instance_eval &block
      interface
    end
  end
end

Aidmock.warn_undefined_interface = true
