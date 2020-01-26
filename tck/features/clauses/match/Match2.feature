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

Feature: Match2 - Match relationships scenarios

  Scenario: Match non-existent relationships returns empty
    Given an empty graph
    When executing query:
      """
      MATCH ()-[r]->()
      RETURN r
      """
    Then the result should be, in any order:
      | r |
    And no side effects

  Scenario: Matching a relationship pattern using a label predicate on both sides
    Given an empty graph
    And having executed:
      """
      CREATE (:A)-[:T1]->(:B),
             (:B)-[:T2]->(:A),
             (:B)-[:T3]->(:B),
             (:A)-[:T4]->(:A)
      """
    When executing query:
      """
      MATCH (:A)-[r]->(:B)
      RETURN r
      """
    Then the result should be, in any order:
      | r     |
      | [:T1] |
    And no side effects

  Scenario: Matching a self-loop with an undirected relationship pattern
    Given an empty graph
    And having executed:
      """
      CREATE (a)
      CREATE (a)-[:T]->(a)
      """
    When executing query:
      """
      MATCH ()-[r]-()
      RETURN type(r) AS r
      """
    Then the result should be, in any order:
      | r   |
      | 'T' |
    And no side effects

  Scenario: Matching a self-loop with a directed relationship pattern
    Given an empty graph
    And having executed:
      """
      CREATE (a)
      CREATE (a)-[:T]->(a)
      """
    When executing query:
      """
      MATCH ()-[r]->()
      RETURN type(r) AS r
      """
    Then the result should be, in any order:
      | r   |
      | 'T' |
    And no side effects

  Scenario: Match relationship with inline property value
    Given an empty graph
    And having executed:
      """
      CREATE (:A)<-[:KNOWS {name: 'monkey'}]-()-[:KNOWS {name: 'woot'}]->(:B)
      """
    When executing query:
      """
      MATCH (node)-[r:KNOWS {name:'monkey'}]->(a)
      RETURN a
      """
    Then the result should be, in any order:
      | a    |
      | (:A) |
    And no side effects

  Scenario: Match relationships with multiple types
    Given an empty graph
    And having executed:
      """
      CREATE (a {name: 'A'}),
        (b {name: 'B'}),
        (c {name: 'C'}),
        (a)-[:KNOWS]->(b),
        (a)-[:HATES]->(c),
        (a)-[:WONDERS]->(c)
      """
    When executing query:
      """
      MATCH (n)-[r:KNOWS|:HATES]->(x)
      RETURN r
      """
    Then the result should be, in any order:
      | r        |
      | [:KNOWS] |
      | [:HATES] |
    And no side effects