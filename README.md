# fluent-plugin-email-obfuscate

[Fluentd](https://fluentd.org/) filter plugin obfuscate email addresses.

[![CodeFactor](https://www.codefactor.io/repository/github/JamesJJ/fluent-plugin-email-obfuscate/badge)](https://www.codefactor.io/repository/github/JamesJJ/fluent-plugin-email-obfuscate)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-email-obfuscate.svg)](https://badge.fury.io/rb/fluent-plugin-email-obfuscate)
[![Travis CI](https://travis-ci.com/JamesJJ/fluent-plugin-email-obfuscate.svg?branch=master)](https://travis-ci.com/JamesJJ/fluent-plugin-email-obfuscate)

This filter attempts to parse each field in the record, and will obfuscate all or part of any email addresses it finds, by replacing with the same number of asterisks.

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

Use `email_obfuscate` filter.

```
    <filter **>
        @type email_obfuscate
        mode <mode>
        suffix_whitelist <list>
    </filter>
```

### mode (default: partial_name)

mode              | Action | Example
:--               | :--    | :-- 
`domain_only`     | Only replace all characters in the domain part | `testuser@*******.***`
`partial_name`    | Replace all characters in domain and partially in the name | `testu***@*******.***`
`name_substring`  | Replace all characters in name and maintain surrounding context | `My old email address ********@example.com does not work any more`
`full`            | Replace all characters in name and domain part of address | `********@*******.***`

_Note: `.` and `@` are never replaced_

### suffix_whitelist (optional)

A list of suffixes not to obfuscate. For example, with config `suffix_whitelist [".example.com", "@example.com"]` the result would be:

Input                        | Action 
:--                          | :--   
`user@example.com`           | no change
`user@subdomain.example.com` | no change
`user@example.museum`        | obfuscated

## Todo

* Support configuration of which fields to act upon
* Fine grained configuration of email delimiters
* . . .

## Copyright

* Copyright(c) 2018-2019 JamesJJ 
* License
  * Apache License, Version 2.0
