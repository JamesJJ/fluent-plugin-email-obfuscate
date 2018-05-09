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

      def obfuscate(str)
        str.match(/^([^@]+)(@.+)$/){|m| m[1] + m[2].tr('@.a-zA-Z0-9','@.*') } || str
      end

      def deep_process(o)

        case o
        when String
          os = o.scan(/<([^<>]+@[^<>]+)>/)
          o = os.length.zero? ? obfuscate(o) : deep_process(os).join(', ')

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
