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

require File.expand_path("../../../spec_helper", __FILE__)

class Sample; end;
class SampleWithInitializer
  def initialize(name)
    @name = name
  end
end

describe Aidmock::Frameworks::RSpec do
  framework = Aidmock::Frameworks::RSpec

  context ".mocks" do
    context "caller class" do
      it "return the class object" do
        obj = Sample.new
        obj.stub(:some_method)

        framework.mocks[0].klass.should == Sample
      end
    end

    context "method name" do
      it "return the method name as a symbol" do
        obj = mock
        obj.stub(:some_method)

        framework.mocks[0].method.should == :some_method
      end
    end

    context "method result" do
      before :each do
        @obj = mock
      end

      it "return an blank array if no return is defined" do
        @obj.stub(:some_method)
        framework.should have_mock_result([])
      end

      it "return an array with the valid argument if one is passed" do
        @obj.stub(:some_method).and_return("one")
        framework.should have_mock_result(["one"])
      end

      it "return an array with all the returns in case of a multiple return" do
        @obj.stub(:some_method).and_return("one", "two", "three")
        framework.should have_mock_result(["one", "two", "three"])
      end

      it "return the value if it's used as a block" do
        @obj.stub(:some_method) { "value" }
        framework.should have_mock_result(["value"])
      end

      it "handles params for return" do
        @obj.stub(:some_method) { |param| "#{param.haha} messed up"}

        framework.should have_mock_result([" messed up"])
      end
    end

    context "method arguments" do
      before :each do
        @obj = mock
      end

      it "return empty list if has no arguments" do
        @obj.stub(:some_method)

        args = framework.mocks[0].arguments
        framework.mocks[0].arguments.should == []
      end

      it "return a list of arguments if they exists" do
        @obj.stub(:some_method).with("hi", "dear")

        framework.mocks[0].arguments.should have(2).items
      end

      context "any arg matcher" do
        it "get nil as result" do
          @obj.stub(:some_method).with(anything)

          framework.should have_mock_arguments([nil])
        end
      end

      context "no arg matcher" do
        it "get an empty array" do
          @obj.stub(:some_method).with(no_args)

          framework.should have_mock_arguments([])
        end
      end

      context "boolean matcher" do
        it "get true as result" do
          @obj.stub(:some_method).with(boolean)

          framework.should have_mock_arguments([true])
        end
      end

      context "hash including matcher" do
        it "get a hash with key set" do
          @obj.stub(:some_method).with(hash_including(:foo))

          framework.should have_mock_arguments([{:foo => nil}])
        end

        it "get a hash with key and value set" do
          @obj.stub(:some_method).with(hash_including(:foo => "bar"))

          framework.should have_mock_arguments([{:foo => "bar"}])
        end

        it "get a hash with multiple keys and values" do
          @obj.stub(:some_method).with(hash_including(:foo, :foo2 => "bar"))

          framework.should have_mock_arguments([{:foo => nil, :foo2 => "bar"}])
        end
      end

      context "hash not including matcher" do
        it "get a blank hash" do
          @obj.stub(:some_method).with(hash_not_including(:foo))

          framework.should have_mock_arguments([{}])
        end
      end

      context "duck type matcher" do
        it "get a object that responds to duck methods" do
          @obj.stub(:some_method).with(duck_type(:foo, :bar))

          result = framework.mocks[0].arguments[0]
          result.should respond_to(:foo, :bar)
        end
      end

      context "instance of matcher" do
        it "get a object that be an instance of that class" do
          @obj.stub(:some_method).with(instance_of(String))

          result = framework.mocks[0].arguments[0]
          result.should be_an_instance_of(String)
        end

        it "get an object even if object needs an initializer" do
          @obj.stub(:some_method).with(instance_of(SampleWithInitializer))

          result = framework.mocks[0].arguments[0]
          result.should be_an_instance_of(SampleWithInitializer)
        end
      end

      context "kind of matcher" do
        it "get a object that be an instance of that class" do
          @obj.stub(:some_method).with(kind_of(String))

          result = framework.mocks[0].arguments[0]
          result.should be_a_kind_of(String)
        end

        it "get an object even if object needs an initializer" do
          @obj.stub(:some_method).with(kind_of(SampleWithInitializer))

          result = framework.mocks[0].arguments[0]
          result.should be_a_kind_of(SampleWithInitializer)
        end
      end

      context "equality proxy" do
        it "get given value" do
          @obj.stub(:some_method).with("foo")

          framework.should have_mock_arguments(["foo"])
        end
      end

      context "regexp matcher" do
        it "get the regexp" do
          @obj.stub(:some_method).with(/foo/)

          framework.should have_mock_arguments(["(?-mix:foo)"])
        end
      end
    end
  end
end
