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

describe Aidmock::Interface do
  Interface = Aidmock::Interface
  MockDescriptor = Aidmock::Frameworks::MockDescriptor
  MethodDescriptor = Aidmock::MethodDescriptor

  context "#method" do
    it "add a new method" do
      descriptor = mock "method descriptor"
      MethodDescriptor.stub(:new).with("test", "type") { descriptor }

      interface = Interface.new(Object)
      interface.method("test", "type")
      interface.methods.should include(descriptor)
    end

    it "remove old method if it has same name" do
      descriptor = mock "method descriptor", :name => "test"
      descriptor2 = mock "method descriptor"
      MethodDescriptor.stub(:new).with("test", "type") { descriptor }
      MethodDescriptor.stub(:new).with("test", "type2") { descriptor2 }

      interface = Interface.new(Object)
      interface.method("test", "type")
      interface.method("test", "type2")
      interface.methods.should include(descriptor2)
      interface.methods.should_not include(descriptor)
    end
  end

  context "#class_method" do
    it "add a new method" do
      descriptor = mock "method descriptor", :class_method= => true
      MethodDescriptor.stub(:new).with("test", "type") { descriptor }

      interface = Interface.new(Object)
      interface.class_method("test", "type")
      interface.class_methods.should include(descriptor)
    end

    it "remove old method if it has same name" do
      descriptor = mock "method descriptor", :name => "test", :class_method= => true
      descriptor2 = mock "method descriptor", :class_method= => true
      MethodDescriptor.stub(:new).with("test", "type") { descriptor }
      MethodDescriptor.stub(:new).with("test", "type2") { descriptor2 }

      interface = Interface.new(Object)
      interface.class_method("test", "type")
      interface.class_method("test", "type2")
      interface.class_methods.should include(descriptor2)
      interface.class_methods.should_not include(descriptor)
    end
  end

  context "#find_method" do
    it "find the method defined by exact name" do
      interface = Interface.new(Object)
      method = interface.method(:some, nil)
      double = MockDescriptor.new(nil, :some, nil, [])

      interface.find_method(double).should == method
    end

    it "find the method defined by and regular expression" do
      interface = Interface.new(Object)
      method = interface.method(/find_by_.+/, nil)
      double = MockDescriptor.new(nil, :find_by_name, nil, [])

      interface.find_method(double).should == method
    end

    it "find method on class" do
      interface = Interface.new(Object)
      method = interface.class_method(:some, nil)
      double = MockDescriptor.new(Object, :some, nil, [])

      interface.find_method(double).should == method
    end

    it "not find an class method on instance search" do
      interface = Interface.new(Object)
      method = interface.class_method(:some, nil)
      double = MockDescriptor.new(nil, :some, nil, [])

      interface.find_method(double).should == nil
    end

    it "not find an instance method on class search" do
      interface = Interface.new(Object)
      method = interface.method(:some, nil)
      double = MockDescriptor.new(Object, :some, nil, [])

      interface.find_method(double).should == nil
    end
  end
end
