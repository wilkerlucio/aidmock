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
  class Interface
    include Matchers

    attr_reader :klass, :methods, :class_methods

    def initialize(klass)
      @klass = klass
      @methods = []
      @class_methods = []
    end

    def method(name, type, *arguments)
      @methods.delete_if { |md| md.name == name }

      method = MethodDescriptor.new(name, type, *arguments)
      @methods << method
      method
    end

    def class_method(name, type, *arguments)
      @class_methods.delete_if { |md| md.name == name }

      method = MethodDescriptor.new(name, type, *arguments)
      method.class_method = true
      @class_methods << method
      method
    end

    def find_method(mock)
      methods = mock.object.instance_of?(Class) ? @class_methods : @methods
      methods.find do |method|
        if method.name.instance_of? ::Regexp
          method.name.match mock.method.to_s
        else
          method.name == mock.method
        end
      end
    end
  end
end
