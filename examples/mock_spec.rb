$: << File.expand_path("../../lib", __FILE__)
require 'aidmock'

RSpec.configure do |config|
  config.after :each do
    Aidmock.verify
  end
end

class Person
  def first_name
    "some"
  end

  def last_name
    "person"
  end

  def full_name
    fname + " " + lname
  end
end

Aidmock.interface Person do
  method :first_name, String
  method :last_name, String
  method :full_name, String
end

describe Person do
  before :each do
    @person = Person.new
  end

  context ".first_name" do
    it "should return some" do
      @person.should_receive(:first_name).and_return("first")
      @person.stub(:last_name).and_return("last")
      @person.stub(:fname).and_return("fail")
      @person.first_name.should == "first"
    end
  end

  # context ".last_name" do
  #   it "should return person" do
  #     @person.last_name.should == "person"
  #   end
  # end

  # context ".full_name" do
  #   it "should concatenate first_name and last_name" do
  #     @person.stub(:fname) { "first" }
  #     @person.stub(:lname) { "last" }
  #     @person.full_name.should == "first last"
  #   end
  # end
end

# class Other
#   attr_accessor :person
#
#   def initialize(person)
#     @person = person
#   end
#
#   def name_with_something(thing)
#     person.name + " #{thing}"
#   end
# end
#
# describe Other do
#   context ".name_with_something" do
#     it "should add thing to name" do
#       person = Aidmock.stub(Person, :name => "my name")
#
#       other = Other.new(person)
#       other.name_with_something("is cool").should == "my name is cool"
#     end
#   end
# end
