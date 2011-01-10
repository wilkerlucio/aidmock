# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aidmock}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wilker Lucio"]
  s.date = %q{2011-01-10}
  s.description = %q{TODO: longer description of your gem}
  s.email = %q{wilkerlucio@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "README.textile",
     "Rakefile",
     "VERSION",
     "aidmock.gemspec",
     "examples/mock_spec.rb",
     "lib/aidmock.rb",
     "lib/aidmock/basic_object.rb",
     "lib/aidmock/errors.rb",
     "lib/aidmock/frameworks.rb",
     "lib/aidmock/frameworks/rspec.rb",
     "lib/aidmock/interface.rb",
     "lib/aidmock/matchers.rb",
     "lib/aidmock/method_descriptor.rb",
     "lib/aidmock/sanity.rb",
     "lib/aidmock/void_class.rb",
     "spec/aidmock/frameworks/rspec_spec.rb",
     "spec/aidmock/interface_spec.rb",
     "spec/aidmock/matchers_spec.rb",
     "spec/aidmock/method_descriptor_spec.rb",
     "spec/aidmock/sanity_spec.rb",
     "spec/aidmock_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/wilkerlucio/aidmock}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Aidmock, safe mocking and interfacing for Ruby}
  s.test_files = [
    "spec/aidmock/frameworks/rspec_spec.rb",
     "spec/aidmock/interface_spec.rb",
     "spec/aidmock/matchers_spec.rb",
     "spec/aidmock/method_descriptor_spec.rb",
     "spec/aidmock/sanity_spec.rb",
     "spec/aidmock_spec.rb",
     "spec/spec_helper.rb",
     "examples/mock_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

