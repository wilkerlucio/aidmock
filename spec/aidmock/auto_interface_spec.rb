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

class AidmockAutoInterfaceSample
  class << self
    def pb_method; end
    protected
    def pr_method; end
    private
    def pv_method; end
  end

  def ipb_method(arg); end
  protected
  def ipr_method(arg, *args); end
  private
  def ipv_method(*args); end
end

describe Aidmock::AutoInterface do
  context ".define" do
    it "define interface for each class on ancestors chain" do
      m1 = mock
      m2 = mock

      k = mock
      k.stub!(:ancestors) { [m1, m2] }

      Aidmock::AutoInterface.should_receive(:define_interface).with(m1)
      Aidmock::AutoInterface.should_receive(:define_interface).with(m2)

      Aidmock::AutoInterface.define(k)
    end
  end

  context ".define_inteface" do
    it "return false if the interface is already defined" do
      Aidmock.stub!(:has_interface?).with(String) { true }

      Aidmock::AutoInterface.send(:define_interface, String).should be_false
    end

    it "define each do klass methods" do
      klass = mock

      String.stub_chain(:method, :arity) { 0 }
      String.stub_chain(:instance_method, :arity) { 0 }

      Aidmock::AutoInterface.stub!(:klass_methods) { [:test] }
      Aidmock::AutoInterface.stub!(:klass_instance_methods) { [:test2] }
      Aidmock::AutoInterface.stub!(:initialize_interface) { klass }
      Aidmock::AutoInterface.stub!(:method_arity_arguments) { [] }

      klass.should_receive(:class_method).with :test, nil
      klass.should_receive(:method).with :test2, nil

      Aidmock::AutoInterface.send :define_interface, String
    end
  end

  context ".method_arity_arguments" do
    it "return blank array if arity is 0" do
      Aidmock::AutoInterface.send(:method_arity_arguments, 0).should == []
    end

    it "return an array of nils with argument numbers if it's positive" do
      Aidmock::AutoInterface.send(:method_arity_arguments, 2).should == [nil, nil]
    end

    it "return an splat with nil if it's -1" do
      Aidmock::AutoInterface.send(:method_arity_arguments, -1).should == [Aidmock::Matchers::SplatArgMatcher.new(nil)]
    end

    it "return array with required arguments plus splat if negative value" do
      Aidmock::AutoInterface.send(:method_arity_arguments, -4).should == [nil, nil, nil, Aidmock::Matchers::SplatArgMatcher.new(nil)]
    end
  end

  context ".klass_method" do
    it "return all class methods" do
      Aidmock::AutoInterface.send(:klass_methods, AidmockAutoInterfaceSample).should include(:pb_method, :pr_method, :pv_method)
    end
  end

  context ".klass_instance_method" do
    it "return all instance methods" do
      Aidmock::AutoInterface.send(:klass_instance_methods, AidmockAutoInterfaceSample).should include(:ipb_method, :ipr_method, :ipv_method)
    end
  end
end
