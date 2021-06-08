#
# Copyright (c) 2015-2021 "Neo Technology,"
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

Feature: Graph9 - Property existence check

  Scenario: [1] Property existence with dynamic property lookup
    Given an empty graph
    And having executed:
      """
      CREATE (:Person {name: 'foo'}),
             (:Person)
      """
    When executing query:
      """
      MATCH (n:Person)
      WHERE n['name'] IS NOT NULL
      RETURN n
      """
    Then the result should be, in any order:
      | n                       |
      | (:Person {name: 'foo'}) |
    And no side effects

  @skipStyleCheck
  Scenario: [2] Property existence is case insensitive
    Given an empty graph
    And having executed:
      """
      CREATE (a:X {prop: 42}), (:X)
      """
    When executing query:
      """
      MATCH (n:X)
      RETURN n, n.prop Is noT nULl AS b
      """
    Then the result should be, in any order:
      | n               | b     |
      | (:X {prop: 42}) | true  |
      | (:X)            | false |
    And no side effects

  Scenario: [3] Property existence check on non-null node
    Given an empty graph
    And having executed:
      """
      CREATE ({exists: 42})
      """
    When executing query:
      """
      MATCH (n)
      RETURN n.missing IS NOT NULL,
             n.exists IS NOT NULL
      """
    Then the result should be, in any order:
      | n.missing IS NOT NULL | n.exists IS NOT NULL |
      | false                 | true                 |
    And no side effects

  Scenario: [4] Property existence check on optional non-null node
    Given an empty graph
    And having executed:
      """
      CREATE ({exists: 42})
      """
    When executing query:
      """
      OPTIONAL MATCH (n)
      RETURN n.missing IS NOT NULL,
             n.notMissing IS NOT NULL
      """
    Then the result should be, in any order:
      | n.missing IS NOT NULL | n.exists IS NOT NULL |
      | false                 | true                 |
    And no side effects

  Scenario: [5] Property existence check on null node
    Given an empty graph
    When executing query:
      """
      OPTIONAL MATCH (n)
      RETURN n.missing IS NOT NULL
      """
    Then the result should be, in any order:
      | n.missing IS NOT NULL |
      | null                  |
    And no side effects
