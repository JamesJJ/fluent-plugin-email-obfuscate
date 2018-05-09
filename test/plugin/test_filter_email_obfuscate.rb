require "helper"
require "fluent/plugin/filter_email_obfuscate.rb"

class EmailObfuscateFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::EmailObfuscateFilter).configure(conf)
  end
end
