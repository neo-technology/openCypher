# Copyright 2017 "Neo Technology",
# Network Engine for Objects in Lund AB (http://neotechnology.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Feature: Foo

  Scenario: Return literal
    Given an empty graph
    When executing query:
      """
      RETURN 1
      """
    Then the result should be:
      | 1 |
      | 1 |
    And no side effects

  Scenario: Fail
    Given an empty graph
    When executing query:
      """
      RETURN foo()
      """
    Then a SyntaxError should be raised at compile time: UnknownFunction

  @ignore
  Scenario: Ignored
    Given an unsupported step
    When executing query:
      """
      not really a query
      """
