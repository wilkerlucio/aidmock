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

require File.expand_path("../../spec_helper", __FILE__)

describe Aidmock::Sanity do
  context ".sanitize_interfaces" do
    it "check each defined interface" do
      m1 = mock
      m2 = mock

      Aidmock.stub!(:interfaces).and_return({:a => m1, :b => m2})
      Aidmock::Sanity.should_receive(:sanitize_interface).with(m1)
      Aidmock::Sanity.should_receive(:sanitize_interface).with(m2)

      Aidmock::Sanity.sanitize_interfaces
    end
  end

  context ".sanitize_interface" do
    it "check each method defined on interface" do
      m1 = mock
      m2 = mock
      m3 = mock
      m4 = mock
      ca = mock

      interface = Aidmock::Interface.allocate
      interface.stub(:methods).and_return([m1, m2])
      interface.stub(:class_methods).and_return([m3, m4])
      interface.stub(:klass).and_return(ca)

      Aidmock::Sanity.should_receive(:sanitize_method).with(ca, m1)
      Aidmock::Sanity.should_receive(:sanitize_method).with(ca, m2)
      Aidmock::Sanity.should_receive(:sanitize_method).with(ca, m3)
      Aidmock::Sanity.should_receive(:sanitize_method).with(ca, m4)

      Aidmock::Sanity.sanitize_interface(interface)
    end
  end

  context ".sanitize_method" do
    before :each do
      @ca = mock(:allocate => Object)
      @me = mock(:name => :to_s, :arity => 0, :class_method? => false)
    end

    it "verify if method is defined" do
      Aidmock::Sanity.should_receive(:verify_method_defined).with(@ca, @me)
      Aidmock::Sanity.sanitize_method(@ca, @me)
    end

    it "verify if method arity" do
      Aidmock::Sanity.should_receive(:verify_method_arity).with(@ca, @me)
      Aidmock::Sanity.sanitize_method(@ca, @me)
    end
  end

  context ".verify_method_defined" do
    it "raise error if object don't have the method defined" do
      klass = Object
      method = Aidmock::MethodDescriptor.new(:foo_isnt_here, nil)

      expect { Aidmock::Sanity.verify_method_defined(klass, method) }.to raise_error("Aidmock Sanity: method 'foo_isnt_here' is not defined for Object")
    end

    it "don't raise error if object has the method" do
      klass = Object
      method = Aidmock::MethodDescriptor.new(:to_s, nil)

      expect { Aidmock::Sanity.verify_method_defined(klass, method) }.to_not raise_error
    end

    it "don't check for regexp methods" do
      klass = String
      method = Aidmock::MethodDescriptor.new(/concat_.*/, nil, [String, Fixnum])

      expect { Aidmock::Sanity.verify_method_arity(klass, method) }.to_not raise_error
    end
  end

  context ".verify_method_arity" do
    it "raise error if arity is different" do
      klass = String
      method = Aidmock::MethodDescriptor.new(:gsub, nil)

      expect { Aidmock::Sanity.verify_method_arity(klass, method) }.to raise_error("Aidmock Sanity: method 'gsub' of String mismatch interface arity, -1 for 0")
    end

    it "not raise error if arity is same" do
      klass = String
      method = Aidmock::MethodDescriptor.new(:concat, nil, [String, Fixnum])

      expect { Aidmock::Sanity.verify_method_arity(klass, method) }.to_not raise_error
    end

    it "don't check for regexp methods" do
      klass = String
      method = Aidmock::MethodDescriptor.new(/concat_.*/, nil, [String, Fixnum])

      expect { Aidmock::Sanity.verify_method_arity(klass, method) }.to_not raise_error
    end
  end
end
