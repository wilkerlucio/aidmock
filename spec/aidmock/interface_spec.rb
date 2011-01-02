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

describe Aidmock::Interface do
  Interface = Aidmock::Interface
  MockDescriptor = Aidmock::Frameworks::MockDescriptor

  context "verifying mocks" do
    context "when mock don't matches interface" do
      before :each do
        @interface = Interface.new(Object)
      end

      it "raise error if method is not defined" do
        double = MockDescriptor.new(nil, :bar, nil, [])

        expect { @interface.verify(double) }.to raise_error(Aidmock::MethodInterfaceNotDefinedError)
      end

      it "invoke verify on method descriptor if method is defined" do
        double = MockDescriptor.new(nil, :bar, "", [])
        method = mock
        method.should_receive(:verify).with(double)

        @interface.stub(:find_method).with(double).and_return(method)
        @interface.verify(double)
      end
    end
  end
end
