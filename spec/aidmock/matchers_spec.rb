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

describe Aidmock::Matchers do
  m = ::Aidmock::Matchers

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

  context "create matcher by value" do
    it "use the matcher if one is sent" do
      m.create(trueMatch).should == trueMatch
    end

    it "use an AnyMatcher if an array is sent" do
      m.create([trueMatch, falseMatch]).should be_an_instance_of(m::AnyMatcher)
    end

    it "use KindOfMatcher if a class is sent" do
      m.create(String).should be_an_instance_of(m::KindOfMatcher)
    end

    it "use AnythingMatcher if nil is sent" do
      m.create(nil).should be_an_instance_of(m::AnythingMatcher)
    end

    it "use DuckTypeMatcher if receive a symbol" do
      m.create(:to_s).should be_an_instance_of(m::DuckTypeMatcher)
    end

    it "use HashMatcher if receive a hash" do
      m.create(:name => nil).should be_an_instance_of(m::HashMatcher)
    end

    it "raise error if can't figure a matcher" do
      expect { m.create("") }.to raise_error
    end
  end

  context "matchers" do
    context "AnyMatcher" do
      it "pass if any of matchers matches" do
        matcher = m::AnyMatcher.new(falseMatch, trueMatch)
        matcher.should matches("obj")
      end

      it "fails if no matcher can match" do
        matcher = m::AnyMatcher.new(falseMatch, falseMatch)
        matcher.should_not matches("obj")
      end
    end

    context "AnythingMatcher" do
      it "always pass" do
        matcher = m::AnythingMatcher.new
        matcher.should matches("something")
      end

      it "should pass with nil" do
        matcher = m::AnythingMatcher.new
        matcher.should matches(nil)
      end
    end

    context "DuckTypeMatcher" do
      it "pass if object respond to all methods" do
        matcher = m::DuckTypeMatcher.new(:to_s, :gsub)
        matcher.should matches("string")
      end

      it "pass if object is nil" do
        matcher = m::DuckTypeMatcher.new(:to_s, :gsub)
        matcher.should matches(nil)
      end

      it "fail if object don't respond to any of methods" do
        matcher = m::DuckTypeMatcher.new(:to_s, :gsub, :i_fail_things)
        matcher.should_not matches("string")
      end
    end

    context "InstanceOfMatcher" do
      it "pass if the object is an instance of given" do
        matcher = m::InstanceOfMatcher.new(String)
        matcher.should matches("string")
      end

      it "pass if the object is nil" do
        matcher = m::InstanceOfMatcher.new(String)
        matcher.should matches(nil)
      end

      it "fail if object is not an instance of given" do
        matcher = m::InstanceOfMatcher.new(Numeric)
        matcher.should_not matches(4)
      end
    end

    context "KindOfMatcher" do
      it "pass if the object is an instance of given" do
        matcher = m::KindOfMatcher.new(String)
        matcher.should matches("string")
      end

      it "pass if the object is an kind of given" do
        matcher = m::KindOfMatcher.new(Numeric)
        matcher.should matches(4)
      end

      it "pass if the object is nil" do
        matcher = m::KindOfMatcher.new(String)
        matcher.should matches(nil)
      end

      it "fail if object is not an instance of given" do
        matcher = m::KindOfMatcher.new(String)
        matcher.should_not matches(4)
      end
    end

    context "HashMatcher" do
      context "flexible mode" do
        it "pass if hash contains only valid keys" do
          matcher = m::HashMatcher.new(:name => trueMatch, :email => falseMatch)
          matcher.should matches(:name => "hi")
        end

        it "pass if the object is nil" do
          matcher = m::HashMatcher.new(:name => trueMatch, :email => falseMatch)
          matcher.should matches(nil)
        end

        it "fails if send an invalid key to hash" do
          matcher = m::HashMatcher.new(:name => trueMatch, :email => trueMatch)
          matcher.should_not matches(:other => "hi")
        end

        it "fails if send a valid key with invalid value" do
          matcher = m::HashMatcher.new(:name => falseMatch, :email => trueMatch)
          matcher.should_not matches(:name => "bar")
        end
      end

      context "strict mode" do
        it "pass if hash contains all valid keys" do
          matcher = m::HashMatcher.new({:name => trueMatch, :email => trueMatch}, true)
          matcher.should matches(:name => "hi", :email => "ho")
        end

        it "fails if any key is missing" do
          matcher = m::HashMatcher.new({:name => trueMatch, :email => trueMatch}, true)
          matcher.should_not matches(:name => "hi")
        end

        it "fails if has extra keys" do
          matcher = m::HashMatcher.new({:name => trueMatch, :email => trueMatch}, true)
          matcher.should_not matches(:name => "hi", :email => "ho", :other => "hu")
        end
      end
    end

    context "NotNilArgMatcher" do
      it "pass if internal matcher pass" do
        matcher = m::NotNilArgMatcher.new(trueMatch)
        matcher.should matches("hi")
      end

      it "fails if internal matcher fails" do
        matcher = m::NotNilArgMatcher.new(falseMatch)
        matcher.should_not matches("hi")
      end

      it "fails if object is nil" do
        matcher = m::NotNilArgMatcher.new(trueMatch)
        matcher.should_not matches(nil)
      end
    end

    context "OptionalArgMatcher" do
      it "just call match at given matcher" do
        matcher = m::OptionalArgMatcher.new(trueMatch)
        matcher.should matches("thing")
      end
    end

    context "SplatArgMatcher" do
      it "use anything matcher by default" do
        matcher = m::SplatArgMatcher.new
        matcher.should matches([true])
      end

      it "should try to match every given value at splat" do
        matcher = m::SplatArgMatcher.new(trueMatch)
        trueMatch.should_receive(:match?).with(1) { true }
        trueMatch.should_receive(:match?).with(2) { true }
        trueMatch.should_receive(:match?).with(3) { true }

        matcher.should matches([1, 2, 3])
      end

      it "fail if any of args don't respect matcher" do
        matcher = m::SplatArgMatcher.new(trueMatch)
        trueMatch.stub(:match?).with(1) { true }
        trueMatch.stub(:match?).with(2) { false }
        trueMatch.stub(:match?).with(3) { true }

        matcher.should_not matches([1, 2, 3])
      end
    end
  end
end
