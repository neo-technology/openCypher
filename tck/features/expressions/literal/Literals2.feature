#
# Copyright (c) 2015-2019 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
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
#
# Attribution Notice under the terms of the Apache License 2.0
#
# This work was created by the collective efforts of the openCypher community.
# Without limiting the terms of Section 6, any Derivative Work that is not
# approved by the public consensus process of the openCypher Implementers Group
# should not be described as “Cypher” (and Cypher® is a registered trademark of
# Neo4j Inc.) or as "openCypher". Extensions by implementers or prototypes or
# proposals for change that have been documented or implemented should only be
# described as "implementation extensions to Cypher" or as "proposed changes to
# Cypher that are not yet approved by the openCypher community".
#

#encoding: utf-8

Feature: Literals2 - Integer

  Background:
    Given any graph

  Scenario: [1] Return a short positive integer
    When executing query:
      """
      RETURN 1 AS literal
      """
    Then the result should be:
      | literal |
      | 1       |
    And no side effects

  Scenario: [2] Return a long positive integer
    When executing query:
      """
      RETURN 372036854 AS literal
      """
    Then the result should be:
      | literal    |
      | 372036854  |
    And no side effects

  Scenario: [3] Return the largest integer
    When executing query:
      """
      RETURN 9223372036854775807 AS literal
      """
    Then the result should be:
      | literal              |
      | 9223372036854775807  |
    And no side effects

  Scenario: [4] Return a positive zero
    When executing query:
      """
      RETURN 0 AS literal
      """
    Then the result should be:
      | literal |
      | 0       |
    And no side effects

  Scenario: [5] Return a negative zero
    When executing query:
      """
      RETURN -0 AS literal
      """
    Then the result should be:
      | literal |
      | 0       |
    And no side effects

  Scenario: [6] Return a short negative integer
    When executing query:
      """
      RETURN -1 AS literal
      """
    Then the result should be:
      | literal |
      | -1      |
    And no side effects

  Scenario: [7] Return a long negative integer
    When executing query:
      """
      RETURN -372036854 AS literal
      """
    Then the result should be:
      | literal    |
      | -372036854 |
    And no side effects

  Scenario: [8] Return the smallest integer
    When executing query:
      """
      RETURN -9223372036854775808 AS literal
      """
    Then the result should be:
      | literal              |
      | -9223372036854775808 |
    And no side effects

  Scenario: [9] Return a short positive hexadecimal integer
    When executing query:
      """
      RETURN 0x1 AS literal
      """
    Then the result should be:
      | literal |
      | 1       |
    And no side effects

  Scenario: [10] Return a long positive hexadecimal integer
    When executing query:
      """
      RETURN 0x162CD4F6 AS literal
      """
    Then the result should be:
      | literal    |
      | 372036854  |
    And no side effects

  Scenario: [11] Return the largest hexadecimal integer
    When executing query:
      """
      RETURN 0x7FFFFFFFFFFFFFFF AS literal
      """
    Then the result should be:
      | literal              |
      | 9223372036854775807  |
    And no side effects

  Scenario: [12] Return a positive hexadecimal zero
    When executing query:
      """
      RETURN 0x0 AS literal
      """
    Then the result should be:
      | literal |
      | 0       |
    And no side effects

  Scenario: [13] Return a negative hexadecimal zero
    When executing query:
      """
      RETURN -0x0 AS literal
      """
    Then the result should be:
      | literal |
      | 0       |
    And no side effects

  Scenario: [14] Return a short negative hexadecimal integer
    When executing query:
      """
      RETURN -0x1 AS literal
      """
    Then the result should be:
      | literal |
      | -1      |
    And no side effects

  Scenario: [15] Return a long negative hexadecimal integer
    When executing query:
      """
      RETURN -0x162CD4F6 AS literal
      """
    Then the result should be:
      | literal    |
      | -372036854 |
    And no side effects

  Scenario: [16] Return the smallest hexadecimal integer
    When executing query:
      """
      RETURN -0x8000000000000000 AS literal
      """
    Then the result should be:
      | literal              |
      | -9223372036854775808 |
    And no side effects
