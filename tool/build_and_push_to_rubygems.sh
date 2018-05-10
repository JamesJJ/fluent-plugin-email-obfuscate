#!/bin/bash

rm -f ./*.gem
gem build fluent-plugin-email-obfuscate.gemspec && \
  gem push fluent-plugin-email-obfuscate-*.gem
rm -f ./*.gem

