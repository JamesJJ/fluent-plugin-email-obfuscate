#
# Copyright 2018 JamesJJ <jj@fcg.fyi>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/filter"

module Fluent
  module Plugin
    class EmailObfuscateFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("email_obfuscate", self)

      config_param :mode, :string, default: 'partial_name',
        desc: <<-DESC
'full' will replace all characters.
'partial_name' will replace all characters in the 'domain' half of the address, and a subset of the 'name'.
'domain_only' will only replace characters in the 'domain' half of the address.
'.' and '@' are never replaced.
DESC

      config_param :suffix_whitelist, :array, default: [],
        desc: <<-DESC
List of email suffixes not to obfuscate e.g. ['@example.com', '.example.com'] would result in:
user@example.com => unchanged
user@subdomain.example.com => unchanged
user@example.net => obfuscated
DESC

      def configure(conf)
        super

        if conf.has_key?('mode')
          raise ConfigError, "'mode' must be one of: domain_only, full, partial_name" unless
            ['domain_only', 'full', 'partial_name'].include?(conf.dig('mode'))
        end
      end

      def hide_partial(str)
          case
          when str.length < 5
            len = str.length
          when str.length < 11
            len = (str.length / 2) + 2
          else
            len = (str.length / 3) + 4
          end
          str[0, len] + '*' * (str.length - len)
      end

      def obfuscate(str)
        strmatch = str.match(/^([^@]+)(@.+)$/) { |m|
           case @mode
           when 'domain_only'
             m[1] + m[2].tr("@.a-zA-Z0-9", "@.*")
           when 'full'
             m[1].gsub(/./, '*') + m[2].tr("@.a-zA-Z0-9", "@.*")
           else
             hide_partial(m[1]) + m[2].tr("@.a-zA-Z0-9", "@.*")
           end
        }
        if strmatch.nil?
          str
        elsif @suffix_whitelist.select{ |a| str.downcase.end_with?(a.downcase)}.empty?
          strmatch
        else
          str
        end
      end

      def deep_process(o)
        case o
        when String
          os = o.scan(/<([^<>]+@[^<>]+)>/)
          o = os.length.zero? ? obfuscate(o) : deep_process(os).join(", ")
        when Array
          o.map! do |obj|
            deep_process(obj)
          end
        when Hash
          o.each_pair do |key, value|
            o[key] = deep_process(value)
          end
        end
        o
      end

      def filter(tag, time, record)
        deep_process(record)
      end
    end
  end
end
