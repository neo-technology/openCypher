#
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

Feature: Unwind

  Scenario: Unwinding a literal list
    Given any graph
    When executing query:
      """
      UNWIND [1, 2, 3] AS x
      RETURN x
      """
    Then the result should be:
      | x |
      | 1 |
      | 2 |
      | 3 |
    And no side effects

  Scenario: Unwinding a range
    Given any graph
    When executing query:
      """
      UNWIND range(1, 3) AS x
      RETURN x
      """
    Then the result should be:
      | x |
      | 1 |
      | 2 |
      | 3 |
    And no side effects

  Scenario: Unwinding a concatenation of lists
    Given any graph
    When executing query:
      """
      WITH [1, 2, 3] AS first, [4, 5, 6] AS second
      UNWIND (first + second) AS x
      RETURN x
      """
    Then the result should be:
      | x |
      | 1 |
      | 2 |
      | 3 |
      | 4 |
      | 5 |
      | 6 |
    And no side effects

  Scenario: Unwinding a collected unwound expression
    Given any graph
    When executing query:
      """
      UNWIND range(1, 2) AS row
      WITH collect(row) AS rows
      UNWIND rows AS x
      RETURN x
      """
    Then the result should be:
      | x |
      | 1 |
      | 2 |
    And no side effects

  Scenario: Unwinding a collected list of nodes
    Given an empty graph
    And having executed:
      """
      CREATE ({id: 1}), ({id: 2})
      """
    When executing query:
      """
      MATCH (row)
      WITH collect(row) AS rows
      UNWIND rows AS node
      RETURN node.id
      """
    Then the result should be:
      | node.id |
      | 1       |
      | 2       |
    And no side effects

  Scenario: Unwinding a parameter list
    Given an empty graph
    And having executed:
      """
      CREATE (:Year {year: 2016})
      """
    And parameters are:
      | values | [true, false, 'unknown'] |
    When executing query:
      """
      UNWIND $values AS v
      RETURN v
      """
    Then the result should be:
      | v         |
      | true      |
      | false     |
      | 'unknown' |
    And no side effects

  Scenario: Double unwinding a list of lists
    Given any graph
    When executing query:
      """
      WITH [[1, 2, 3], [4, 5, 6]] AS lol
      UNWIND lol AS x
      UNWIND x AS y
      RETURN y
      """
    Then the result should be:
      | y |
      | 1 |
      | 2 |
      | 3 |
      | 4 |
      | 5 |
      | 6 |
    And no side effects

  Scenario: Unwinding the empty list
    Given any graph
    When executing query:
      """
      UNWIND [] AS empty
      RETURN empty
      """
    Then the result should be:
      | empty |
    And no side effects

  Scenario: Unwinding null
    Given any graph
    When executing query:
      """
      UNWIND null AS nil
      RETURN nil
      """
    Then the result should be:
      | nil |
    And no side effects

  Scenario: Unwinding non-empty lists, empty lists, and nulls
    Given any graph
    When executing query:
      """
      UNWIND [[], [1, 2], null, [], [5, 6], null] AS elements
      UNWIND elements AS var1
      UNWIND var1 AS var2
      RETURN var2, var1
      """
    Then the result should be:
      | elements | var1 | var2 |
      | [1, 2]   | 1    | 1    |
      | [1, 2]   | 2    | 2    |
      | [5, 6]   | 5    | 5    |
      | [5, 6]   | 6    | 6    |
    And no side effects

  Scenario: Unwinding list with duplicates
    Given any graph
    When executing query:
      """
      UNWIND [1, 1, 2, 2, 3, 3, 4, 4, 5, 5] AS duplicate
      RETURN duplicate
      """
    Then the result should be:
      | duplicate |
      | 1         |
      | 1         |
      | 2         |
      | 2         |
      | 3         |
      | 3         |
      | 4         |
      | 4         |
      | 5         |
      | 5         |
    And no side effects

  Scenario: UNWIND does not put variables out of scope
    Given any graph
    When executing query:
      """
      WITH [1, 2, 3] AS list
      UNWIND list AS x
      RETURN *
      """
    Then the result should be:
      | list      | x |
      | [1, 2, 3] | 1 |
      | [1, 2, 3] | 2 |
      | [1, 2, 3] | 3 |
    And no side effects

  Scenario: Matching, collecting and unwinding in sophisticated query
    Given an empty graph
    And having executed:
      """
      CREATE (s:S),
        (n),
        (e:E),
        (s)-[:X]->(e),
        (s)-[:Y]->(e),
        (n)-[:Y]->(e)
      """
    When executing query:
      """
      MATCH (a:S)-[:X]->(b1)
      WITH a, collect(b1) AS bees
      UNWIND bees AS b2
      MATCH (a)-[:Y]->(b2)
      RETURN a, b2
      """
    Then the result should be:
      | a    | b2   |
      | (:S) | (:E) |
    And no side effects

  Scenario: Multiple unwinds after each other
    Given any graph
    When executing query:
      """
      WITH [1, 2] AS xs, [3, 4] AS ys, [5, 6] AS zs
      UNWIND xs AS x
      UNWIND ys AS y
      UNWIND zs AS z
      RETURN *
      """
    Then the result should be:
      | x | y | z | zs     | ys     | xs     |
      | 1 | 3 | 5 | [5, 6] | [3, 4] | [1, 2] |
      | 1 | 3 | 6 | [5, 6] | [3, 4] | [1, 2] |
      | 1 | 4 | 5 | [5, 6] | [3, 4] | [1, 2] |
      | 1 | 4 | 6 | [5, 6] | [3, 4] | [1, 2] |
      | 2 | 3 | 5 | [5, 6] | [3, 4] | [1, 2] |
      | 2 | 3 | 6 | [5, 6] | [3, 4] | [1, 2] |
      | 2 | 4 | 5 | [5, 6] | [3, 4] | [1, 2] |
      | 2 | 4 | 6 | [5, 6] | [3, 4] | [1, 2] |
    And no side effects

  Scenario: UNWIND and MERGE
    Given an empty graph
    And parameters are:
      | props | [{login: 'login', name: 'name'}, {login: 'login', name: 'name'}] |
    When executing query:
      """
      UNWIND $props AS prop
      MERGE (p:Person {login: prop.login})
      ON CREATE SET p.name = prop.name
      RETURN p.name, p.login
      """
    Then the result should be:
      | p.name | p.login |
      | 'name' | 'login' |
      | 'name' | 'login' |
    And the side effects should be:
      | +nodes      | 1 |
      | +labels     | 1 |
      | +properties | 2 |

  Scenario: Unwinding non-lists repeatedly
    Given an empty graph
    And having executed:
      """
      CREATE (:A)-[:T]->(:B)
      """
    When executing query:
      """
      MATCH p = (a:A)-[r:T]->()
      UNWIND [1, 3.14, true, 'string', {}, a, r, p] AS nonList
      UNWIND nonList AS alias1
      UNWIND nonList AS alias2
      RETURN nonList, alias1, alias2
      """
    Then the result should be:
      | nonList           | alias1            | alias2            |
      | 1                 | 1                 | 1                 |
      | 3.14              | 3.14              | 3.14              |
      | true              | true              | true              |
      | 'string'          | 'string'          | 'string'          |
      | {}                | {}                | {}                |
      | (:A)              | (:A)              | (:A)              |
      | [:T]              | [:T]              | [:T]              |
      | <(:A)-[:T]->(:B)> | <(:A)-[:T]->(:B)> | <(:A)-[:T]->(:B)> |
    And no side effects

  Scenario: Unwinding a list property
    Given an empty graph
    And having executed:
      """
      CREATE (:Person {name: 'Alice', languages: ['en', 'de', 'gr']}),
        (:Person {name: 'Bob', languages: ['en', 'de']}),
        (:Person {name: 'Cecil', languages: []}),
        (:Person {name: 'Dennis'})
      """
    When executing query:
      """
      MATCH (n:Person)
      UNWIND n.languages AS lang
      RETURN n.name, lang
      """
    Then the result should be:
      | n.name  | lang |
      | 'Alice' | 'en' |
      | 'Alice' | 'de' |
      | 'Alice' | 'gr' |
      | 'Bob'   | 'en' |
      | 'Bob'   | 'de' |
    And no side effects
