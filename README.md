# fluent-plugin-email-obfuscate

[Fluentd](https://fluentd.org/) filter plugin obfuscate email addresses.

[![CodeFactor](https://www.codefactor.io/repository/github/JamesJJ/fluent-plugin-email-obfuscate/badge)](https://www.codefactor.io/repository/github/JamesJJ/fluent-plugin-email-obfuscate)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-email-obfuscate.svg)](https://badge.fury.io/rb/fluent-plugin-email-obfuscate)

This filter attempts to parse each field in the record, and will replace the "domain" part of the email address with asterisks.

### For example:

#### Record Input:

```
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
  "email_string": "Jane Doe <jane@example.name>, John Smith <john@example.name>"
}
```

#### Record Output:

```
 {
  "f1": "myEmail@*******.***",
  "list1": [
    "user1@*******.***",
    "user2@*******.***"
  ],
  "a": {
    "nested": {
      "field": "name3@*******.******"
    }
  },
  "email_string": "jane@*******.****, john@*******.****"
}
```

## Installation

### RubyGems

```
$ gem install fluent-plugin-email-obfuscate
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-email-obfuscate"
```

And then execute:

```
$ bundle
```

## Configuration

_CURRENTLY THIS FILTER DOES NOT ACCEPT ANY CONFIGURATION_

<!---
You can generate configuration template:

```
$ fluent-plugin-config-format filter email-obfuscate
```

You can copy and paste generated documents here.
-->

## Todo

* Add tests!
* Support whitelists of domains not to be obfuscated
* Support configuration of which fields to act upon
* . . .

## Copyright

* Copyright(c) 2018 JamesJJ 
* License
  * Apache License, Version 2.0
