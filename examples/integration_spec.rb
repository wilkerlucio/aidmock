$: << File.expand_path("../../lib", __FILE__)
require 'aidmock'

RSpec.configure do |config|
  config.before :all do
    Aidmock.setup
  end

  config.after :each do
    Aidmock.verify
  end
end

class Address
  def full_address
    "testing"
  end
end

class Person
  def name
    "John"
  end

  def full_info(address)
    "#{name} - #{address.full_address}"
  end
end

Aidmock.interface Person do
  method :name, String
  method :full_info, String, :full_address
end

Aidmock.interface Address do
  method :full_address, String
end

Aidmock::Sanity.sanitize

describe Person do
  before :each do
    @person = Person.new
  end

  context ".full_info" do
    it "should return some" do
      address = mock.constrained_to(Address)
      address.stub(:full_address) { "my street" }

      @person.stub(:name).and_return("my name")

      @person.full_info(address).should == "my name - my street"
    end
  end
end
