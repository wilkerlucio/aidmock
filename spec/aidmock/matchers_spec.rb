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

describe Aidmock::Matchers do
  context "factory matcher by value" do
    it "use the matcher if one is sent"
    it "use an AnyMatcher if an array is sent"
    it "use KindOfMatcher if a class is sent"
    it "raise error if can't figure a matcher"
  end

  context "matchers" do
    context "AnyMatcher" do
      it "pass if any of matchers matches"
      it "fails if no matcher can match"
    end

    context "DuckTypeMatcher" do
      it "pass if object respond to all methods"
      it "fail if object don't respond to any of methods"
    end

    context "InstanceOfMatcher" do
      it "pass if the object is an instance of given"
      it "fail if object is not an instance of given"
    end

    context "KindOfMatcher" do
      it "pass if the object is a kind of given"
      it "fail if the object is not a kind of given"
    end
  end
end
