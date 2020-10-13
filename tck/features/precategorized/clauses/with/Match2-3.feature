#
# Copyright (c) 2015-2020 "Neo Technology,"
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

Feature: Match2-3 - Match relationships WITH clause scenarios

  # WithOrderByLimit
  Scenario: Ordering and limiting on aggregate
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T1 {num: 3}]->(x:X),
             ()-[:T2 {num: 2}]->(x:X),
             ()-[:T3 {num: 1}]->(:Y)
      """
    When executing query:
      """
      MATCH ()-[r1]->(x)
      WITH x, sum(r1.num) AS c
        ORDER BY c LIMIT 1
      RETURN x, c
      """
    Then the result should be, in any order:
      | x    | c |
      | (:Y) | 1 |
    And no side effects

  # WithOrderBySkip
  Scenario: Ordering and skipping on aggregate
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T1 {num: 3}]->(x:X),
             ()-[:T2 {num: 2}]->(x:X),
             ()-[:T3 {num: 1}]->(:Y)
      """
    When executing query:
      """
      MATCH ()-[r1]->(x)
      WITH x, sum(r1.num) AS c
        ORDER BY c SKIP 1
      RETURN x, c
      """
    Then the result should be, in any order:
      | x    | c |
      | (:X) | 5 |
    And no side effects

  # WithOrderBy
  Scenario: Matching using a relationship that is already bound, in conjunction with aggregation and ORDER BY
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T1 {id: 0}]->(:X),
             ()-[:T2 {id: 1}]->(:X),
             ()-[:T2 {id: 2}]->()
      """
    When executing query:
      """
      MATCH (a)-[r]->(b:X)
      WITH a, r, b, count(*) AS c
        ORDER BY c
      MATCH (a)-[r]->(b)
      RETURN r AS rel
        ORDER BY rel.id
      """
    Then the result should be, in order:
      | rel           |
      | [:T1 {id: 0}] |
      | [:T2 {id: 1}] |
    And no side effects
