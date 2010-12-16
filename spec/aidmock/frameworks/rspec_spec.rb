require File.expand_path("../../../spec_helper", __FILE__)

class Sample; end;

shared_examples_for "Mock Definition" do
  it "have correct class" do
    @stub.klass.should == Sample
  end

  it "have corret method" do
    @stub.method.should == :some_method
  end

  it "have corrent result" do
    @stub.result.should == "something"
  end

  it "have a method collection" do
    @stub.arguments.should be_instance_of(Aidmock::ArgumentList)
  end
end

describe Aidmock::Frameworks::RSpec do
  framework = Aidmock::Frameworks::RSpec

  context ".mocks" do
    context "getting defined stub" do
      before :each do
        obj = Sample.new
        obj.stub(:some_method) { "something" }

        @stub = framework.mocks[0]
      end

      it_should_behave_like "Mock Definition"
    end

    context "getting defined mock" do
      before :each do
        obj = Sample.new
        obj.should_receive(:some_method).and_return("something")
        obj.some_method

        @stub = framework.mocks[0]
      end

      it_should_behave_like "Mock Definition"
    end
  end
end
