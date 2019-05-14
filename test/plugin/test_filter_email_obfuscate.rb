require "helper"
require "fluent/plugin/filter_email_obfuscate.rb"

class EmailObfuscateFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONF = %[
  ]

  def test_configure
    d = create_driver
    assert_equal :partial_name, d.instance.mode
    assert_equal [], d.instance.suffix_whitelist
  end

  def sample_records
    {
      "f1": "myEmail@example.net",
      "list1": [
        "user1@example.com",
        "user2@example.org"
      ],
      "a": {
        "nested": {
          "field": "name3@example.museum"
        }
      },
      "email_string": "Jane Doe <jane@example.name>, John Smith <john@example.name>",
      "email_string_with_trailing_text": "Jane Doe <jane@example.name>, John Smith <john@example.name> trailing text is here"
    }
  end

  test "invalid mode" do
    assert_raise(Fluent::ConfigError) do
      create_driver(CONF + %[mode invalid])
    end
  end

  test "filter" do
    d = create_driver
    d.run(default_tag: 'test') do
      d.feed(sample_records)
    end
    expected = [{f1: "myEma**@*******.***",
                 list1: ["user*@*******.***", "user*@*******.***"],
                 a: {nested:
                       {field: "name*@*******.******"}},
                 email_string: "jane@*******.****, john@*******.****",
                 email_string_with_trailing_text: "jane@*******.****, john@*******.****"}
               ]
    assert_equal expected, d.filtered.map{|e| e.last}
  end

  test "filter_full" do
    d = create_driver(CONF + %[mode full])
    d.run(default_tag: 'test') do
      d.feed(sample_records)
    end
    expected = [{f1: "*******@*******.***",
                 list1: ["*****@*******.***", "*****@*******.***"],
                 a: {nested:
                       {field: "*****@*******.******"}},
                 email_string: "****@*******.****, ****@*******.****",
                 email_string_with_trailing_text: "****@*******.****, ****@*******.****"}
               ]
    assert_equal expected, d.filtered.map{|e| e.last}
  end

  test "filter_domain_only" do
    d = create_driver(CONF + %[mode domain_only])
    d.run(default_tag: 'test') do
      d.feed(sample_records)
    end
    expected = [{f1: "myEmail@*******.***",
                 list1: ["user1@*******.***", "user2@*******.***"],
                 a: {nested:
                       {field: "name3@*******.******"}},
                 email_string: "jane@*******.****, john@*******.****",
                 email_string_with_trailing_text: "jane@*******.****, john@*******.****"}
               ]
    assert_equal expected, d.filtered.map{|e| e.last}
  end

  test "filter_name_substring" do
    d = create_driver(CONF + %[mode name_substring])
    d.run(default_tag: 'test') do
      d.feed(sample_records)
    end
    expected = [{f1: "*******@example.net",
                 list1: ["*****@example.com", "*****@example.org"],
                 a: {nested:
                       {field: "*****@example.museum"}},
                 email_string: "Jane Doe <****@example.name>, John Smith <****@example.name>",
                 email_string_with_trailing_text: "Jane Doe <****@example.name>, John Smith <****@example.name> trailing text is here"}
               ]
    assert_equal expected, d.filtered.map{|e| e.last}
  end

  test "suffix whitelist" do
    d = create_driver(CONF + %[suffix_whitelist [".example.com", "@example.com"]\nmode partial_name])
    sample_records = {
      "f1": "myEmail@example.net",
      "list1": [
        "user1@example.com",
        "user2@subdomain.example.com"
      ],
      "a": {
        "nested": {
          "field": "name3@example.museum"
        }
      },
      "email_string": "Jane Doe <jane@example.name>, John Smith <john@example.name>"
    }
    d.run(default_tag: 'test') do
      d.feed(sample_records)
    end
    expected = [{f1: "myEma**@*******.***",
                 list1: ["user1@example.com", "user2@subdomain.example.com"],
                 a: {nested:
                       {field: "name*@*******.******"}},
                 email_string: "jane@*******.****, john@*******.****"}]
    assert_equal expected, d.filtered.map{|e| e.last}
  end

  test "suffix whitelist mode name_substring" do
    d = create_driver(CONF + %[suffix_whitelist [".example.com", "@example.com"]\nmode name_substring])
    sample_records = {
      "f1": "myEmail@example.net",
      "list1": [
        "user1@example.com",
        "user2@subdomain.example.com"
      ],
      "a": {
        "nested": {
          "field": "name3@example.museum"
        }
      },
      "email_string": "Jane Doe <jane@example.name>, John Smith <john@example.name> and some trailing text"
    }
    d.run(default_tag: 'test') do
      d.feed(sample_records)
    end
    expected = [{f1: "*******@example.net",
                 list1: ["user1@example.com", "user2@subdomain.example.com"],
                 a: {nested:
                       {field: "*****@example.museum"}},
                 email_string: "Jane Doe <****@example.name>, John Smith <****@example.name> and some trailing text"}]


    assert_equal expected, d.filtered.map{|e| e.last}
  end


  private

  def create_driver(conf = CONF)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::EmailObfuscateFilter).configure(conf)
  end
end
