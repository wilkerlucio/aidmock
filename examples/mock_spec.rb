$: << File.expand_path("../../lib", __FILE__)
require 'aidmock'

RSpec.configure do |config|
  config.after :each do
    Aidmock.verify
  end
end

class Person
  def first_name
    "first"
  end

  def last_name
    "last"
  end

  def full_name
    first_name + " " + last_name
  end
end

Aidmock.interface Person do
  method :first_name, String
  method :last_name, String
  method :full_name, String
end

Aidmock::Sanity.sanitize

describe Person do
  before :each do
    @person = Person.new
  end

  context ".first_name" do
    it "should return some" do
      @person.stub(:first_name).and_return("f")
      @person.stub(:last_name).and_return("l")
      @person.full_name.should == "f l"
    end
  end
end
