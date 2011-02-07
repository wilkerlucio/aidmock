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

require File.expand_path("../spec_helper", __FILE__)

describe Aidmock do
  context ".interface" do
    context "automatic interfacing" do
      it "define interface if auto is specified" do
        Aidmock::AutoInterface.should_receive(:define).with(String) {}
        Aidmock.stub!(:interfaces) { {} }

        Aidmock.interface String, :auto => true
      end

      it "don't automatic define interface if auto is false" do
        Aidmock::AutoInterface.should_not_receive(:define)

        Aidmock.interface String
      end
    end
  end

  context ".verify" do
    it "do verify double on each double returned by framework" do
      m1 = mock; m2 = mock; m3 = mock
      framework = stub(:mocks => [m1, m2, m3])
      Aidmock.stub!(:framework) { framework }

      Aidmock.should_receive(:verify_double).with(m1) { nil }
      Aidmock.should_receive(:verify_double).with(m2) { nil }
      Aidmock.should_receive(:verify_double).with(m3) { nil }

      Aidmock.verify!
    end
  end

  context ".verify_double" do
    context "has a chain" do
      it "call to verify chain" do
        double = Aidmock::Frameworks::MockDescriptor.new("object", :to_s, nil, [])

        Aidmock.stub!(:chain_for).with(String) { [String] }
        Aidmock.should_receive(:verify_double_on_chain).with(double, [String])

        Aidmock.send :verify_double, double
      end
    end

    context "don't has a chain" do
      context "autointerace enabled" do
        it "define interface with autointerface" do
          double = Aidmock::Frameworks::MockDescriptor.new("object", :to_s, nil, [])

          Aidmock.stub!(:autointerface?) { true }
          Aidmock.stub!(:has_interface?).with(String) { false }
          Aidmock.stub!(:verify_double_on_chain)
          Aidmock::AutoInterface.should_receive(:define).with(String) {}

          Aidmock.send :verify_double, double
        end
      end

      context "autointerface disabled" do
        it "don't define autointerface and show a warning" do
          double = Aidmock::Frameworks::MockDescriptor.new("object", :to_s, nil, [])

          Aidmock.stub!(:warn_undefined_interface?) { false }
          Aidmock.stub!(:autointerface?) { false }
          Aidmock.stub!(:chain_for).with(String) { [] }
          Aidmock::AutoInterface.should_not_receive(:define).with(String) {}

          Aidmock.send :verify_double, double
        end
      end
    end
  end

  context ".verify_double_on_chain" do
    it "call verify on method descriptor if method exists" do
      double = mock
      chain = mock
      method = mock
      method.should_receive(:verify).with(double)

      Aidmock.stub!(:find_method_on_chain).with(double, chain).and_return(method)

      Aidmock.send(:verify_double_on_chain, double, chain)
    end

    it "raise error if method can't be found" do
      double = stub(:method => nil, :object => nil)
      chain = mock

      Aidmock.stub!(:find_method_on_chain).with(double, chain).and_return(nil)

      expect { Aidmock.send(:verify_double_on_chain, double, chain) }.to raise_error(Aidmock::MethodInterfaceNotDefinedError)
    end
  end

  context ".find_method_on_chain" do
    it "get method if the interface has it" do
      double = stub(:method => :some)
      interface = stub
      interface.stub(:find_method).with(double).and_return(true)

      Aidmock.send(:find_method_on_chain, double, [interface]).should == true
    end

    it "return nil if no interface has the method" do
      double = stub(:method => :some)
      interface = stub
      interface.stub(:find_method).with(double) { nil }

      Aidmock.send(:find_method_on_chain, double, [interface]).should == nil
    end

    it "use first occurence if more than one on chain can respond to method" do
      m1 = mock, m2 = mock
      double = stub(:method => :some)
      interface = stub
      interface.stub(:find_method).with(double) { nil }
      interface2 = stub
      interface2.stub(:find_method).with(double) { m1 }
      interface3 = stub
      interface3.stub(:find_method).with(double) { m2 }

      Aidmock.send(:find_method_on_chain, double, [interface, interface2, interface3]).should == m1
    end
  end

  context ".class_chain" do
    it "get chain of defined interfaces on a class" do
      m1 = mock
      m2 = mock
      Aidmock.stub!(:interfaces).and_return({String => m1, Object => m2, Fixnum => true})
      Aidmock.send(:chain_for, String).should == [m1, m2]
    end
  end

  context ".extract_class" do
    it "return aidmock_class if object responds to it" do
      obj = mock
      obj.stub!(:aidmock_class) { Fixnum }

      Aidmock.send(:extract_class, obj).should == Fixnum
    end

    it "return class itself if object aidmock_class is nil" do
      obj = mock
      obj.stub!(:aidmock_class) { nil }

      Aidmock.send(:extract_class, obj).should == ::RSpec::Mocks::Mock
    end

    it "return the object class if it's an instance" do
      Aidmock.send(:extract_class, "string").should == String
    end

    it "return the object if it's an class" do
      Aidmock.send(:extract_class, String).should == String
    end
  end
end
