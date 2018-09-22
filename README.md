# fluent-plugin-email-obfuscate

[Fluentd](https://fluentd.org/) filter plugin obfuscate email addresses.

[![CodeFactor](https://www.codefactor.io/repository/github/JamesJJ/fluent-plugin-email-obfuscate/badge)](https://www.codefactor.io/repository/github/JamesJJ/fluent-plugin-email-obfuscate)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-email-obfuscate.svg)](https://badge.fury.io/rb/fluent-plugin-email-obfuscate)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FJamesJJ%2Ffluent-plugin-email-obfuscate.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FJamesJJ%2Ffluent-plugin-email-obfuscate?ref=badge_shield)

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

mode            | Action | Example
:--             | :--    | :-- 
`domain_only`   | Only replace all characters in the domain part | `testuser@*******.***`
`partial_name`  | Replace all characters in domain and partially in the name | `testu***@*******.***`
`full`          | Replace all characters in name and domain part of address | `********@*******.***`

_Note: `.` and `@` are never replaced_

### suffix_whitelist (optional)

A list of suffixes not to obfuscate. For example, with config `suffix_whitelist [".example.com", "@example.com"]` the result would be:

Input                        | Action 
:--                          | :--   
`user@example.com`           | no change
`user@subdomain.example.com` | no change
`user@example.museum`        | obfuscated

## Todo

* Add tests!
* Support configuration of which fields to act upon
* . . .

## Copyright

* Copyright(c) 2018 JamesJJ 
* License
  * Apache License, Version 2.0


[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FJamesJJ%2Ffluent-plugin-email-obfuscate.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FJamesJJ%2Ffluent-plugin-email-obfuscate?ref=badge_large)