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

describe Aidmock::MethodDescriptor do
  mock_descriptor = Aidmock::Frameworks::MockDescriptor
  md = Aidmock::MethodDescriptor
  m = Aidmock::Matchers

  trueMatch = Class.new do
    def match?(obj)
      true
    end
  end.new

  falseMatch = Class.new do
    def match?(obj)
      false
    end
  end.new

  def mock_return(val)
    Aidmock::Frameworks::MockDescriptor.new(nil, :some, val)
  end

  def mock_args(args)
    Aidmock::Frameworks::MockDescriptor.new(nil, :some, nil, args)
  end

  it "verify the arguments and return value" do
    double = mock_descriptor.new(nil, :method, :result, [:args])
    desc = md.new(:some, nil)
    desc.should_receive(:verify_arguments).with(double)
    desc.should_receive(:verify_return).with(double)
    desc.verify(double)
  end

  context "verifying return value" do
    it "raise error if return value don't match" do
      desc = md.new(:some, falseMatch)

      expect { desc.verify_return(mock_return([nil])) }.to raise_error(Aidmock::MethodInterfaceReturnNotMatchError)
    end

    it "not raise error if return value match" do
      desc = md.new(:some, trueMatch)

      expect { desc.verify_return(mock_return([nil])) }.to_not raise_error
    end

    it "send double value to matcher" do
      desc = md.new(:some, trueMatch)
      trueMatch.should_receive(:match?).with("hi").and_return(true)
      trueMatch.should_receive(:match?).with("ho").and_return(true)

      desc.verify_return(mock_return(["hi", "ho"]))
    end
  end

  context "verifying arguments" do
    context "testing arguments arity" do
      context "on fixed arguments length" do
        it "raise error if user send less arguments than method expects" do
          desc = md.new(:some, nil, trueMatch, trueMatch)

          expect { desc.verify_arguments(mock_args([5]))}.to raise_error(Aidmock::MethodInterfaceArgumentsNotMatchError, "error on mock method :some, expected 2 arguments, 1 sent")
        end

        it "raise error if user send more arguments than method expects" do
          desc = md.new(:some, nil, trueMatch, trueMatch)

          expect { desc.verify_arguments(mock_args([5, 6, 7]))}.to raise_error(Aidmock::MethodInterfaceArgumentsNotMatchError, "error on mock method :some, expected 2 arguments, 3 sent")
        end

        it "not raise error if they are in correct arity" do
          desc = md.new(:some, nil, trueMatch, trueMatch)

          expect { desc.verify_arguments(mock_args([5, 6]))}.to_not raise_error
        end
      end

      context "on variable arguments length" do
        it "raise error if number of arguments is less than required ones" do
          desc = md.new(:some, nil, trueMatch, Aidmock::Matchers::OptionalArgMatcher.new(trueMatch))

          expect { desc.verify_arguments(mock_args([])) }.to raise_error(Aidmock::MethodInterfaceArgumentsNotMatchError, "error on mock method :some, expected at least 1, 0 sent")
        end

        it "raise error if it has more args than possible (after optional ones)" do
          desc = md.new(:some, nil, trueMatch, Aidmock::Matchers::OptionalArgMatcher.new(trueMatch))

          expect { desc.verify_arguments(mock_args([1, 2, 3])) }.to raise_error(Aidmock::MethodInterfaceArgumentsNotMatchError, "error on mock method :some, expected at most 2, 3 sent")
        end

        it "dont raise error if fits on argument length" do
          desc = md.new(:some, nil, trueMatch, Aidmock::Matchers::OptionalArgMatcher.new(trueMatch))

          expect { desc.verify_arguments(mock_args([1])) }.to_not raise_error
          expect { desc.verify_arguments(mock_args([1, 2])) }.to_not raise_error
        end

        it "dont raise error if has more arguments than max, but has a splat" do
          desc = md.new(:some, nil, trueMatch, Aidmock::Matchers::SplatArgMatcher.new(trueMatch))

          expect { desc.verify_arguments(mock_args([1, 2, 3])) }.to_not raise_error
        end
      end
    end

    context "checking arguments" do
      it "try each argument on respective matcher" do
        m1 = mock
        m2 = mock

        m1.should_receive(:match?).with(1).and_return(true)
        m2.should_receive(:match?).with(2).and_return(true)

        desc = md.new(:some, nil, m1, m2)
        desc.verify_arguments(mock_args([1, 2]))
      end

      it "raise error if any matcher fail" do
        desc = md.new(:some, nil, falseMatch, trueMatch)

        expect { desc.verify_arguments(mock_args([1, 2])) }.to raise_error(Aidmock::MethodInterfaceArgumentsNotMatchError)
      end

      it "send an array with others if has a splat" do
        matcher = mock
        matcher.should_receive(:match?).with(2).and_return(true)
        matcher.should_receive(:match?).with(3).and_return(true)

        desc = md.new(:some, nil, trueMatch, Aidmock::Matchers::SplatArgMatcher.new(matcher))
        desc.verify_arguments(mock_args([1, 2, 3]))
      end
    end
  end

  context "#arity" do
    it "return 0 if no arguments are given" do
      md.new(:some, nil).arity.should == 0
    end

    it "return positive number of arguments if they are regular ones" do
      md.new(:some, nil, nil, nil).arity.should == 2
    end

    it "return -1 if start with optional argument" do
      md.new(:some, nil, m::OptionalArgMatcher.new(nil)).arity.should == -1
    end

    it "return -1 if start with splat argument" do
      md.new(:some, nil, m::SplatArgMatcher.new(nil)).arity.should == -1
    end

    it "return negative value when has both optional and required args" do
      md.new(:some, nil, nil, m::OptionalArgMatcher.new(nil)).arity.should == -2
    end

    it "return negative value when has both splt and required args" do
      md.new(:some, nil, nil, m::SplatArgMatcher.new(nil)).arity.should == -2
    end

    it "return negative when have optional, required and splt args" do
      md.new(:some, nil, nil, m::OptionalArgMatcher.new(nil), m::SplatArgMatcher.new(nil)).arity.should == -2
    end
  end

  context "#required_arity" do
    before :each do
      @m = md.new(:some, nil)
    end

    it "return arity if its positive" do
      @m.stub(:arity).and_return(1)
      @m.required_arity.should == 1
    end

    it "return 0 if arity is 0" do
      @m.stub(:arity).and_return(0)
      @m.required_arity.should == 0
    end

    it "return arity positive less 1 if it's negative" do
      @m.stub(:arity).and_return(-2)
      @m.required_arity.should == 1
    end
  end
end
