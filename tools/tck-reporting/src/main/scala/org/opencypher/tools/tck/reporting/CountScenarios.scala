/*
 * Copyright (c) 2015-2020 "Neo Technology,"
 * Network Engine for Objects in Lund AB [http://neotechnology.com]
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Attribution Notice under the terms of the Apache License 2.0
 *
 * This work was created by the collective efforts of the openCypher community.
 * Without limiting the terms of Section 6, any Derivative Work that is not
 * approved by the public consensus process of the openCypher Implementers Group
 * should not be described as “Cypher” (and Cypher® is a registered trademark of
 * Neo4j Inc.) or as "openCypher". Extensions by implementers or prototypes or
 * proposals for change that have been documented or implemented should only be
 * described as "implementation extensions to Cypher" or as "proposed changes to
 * Cypher that are not yet approved by the openCypher community".
 */
package org.opencypher.tools.tck.reporting

import org.opencypher.tools.tck.api.CypherTCK
import org.opencypher.tools.tck.api.Scenario

trait CountCategory {
  def name: String
  def indent: Int
  def parent: Option[CountCategory]
}

case object Total extends CountCategory {
  val name = "Total"
  val indent = 0
  val parent: Option[CountCategory] = None

  override def toString: String = name
}

case class Tag(name: String) extends CountCategory {
  val indent = 1
  val parent: Option[CountCategory] = Some(Total)

  override def toString: String = "@" + name
}

case class Feature(name: String, indent: Int, parent: Option[CountCategory]) extends CountCategory{
  override def toString: String = "Feature: " + name
}

case class ScenarioCategory(name: String, indent: Int, parent: Option[CountCategory]) extends CountCategory {
  override def toString: String = name
}

/*
 * This is a tiny tool to count TCK scenarios in the list returned by `CypherTCK.allTckScenarios`.
 * At the moment it count scenarios by total, feature, and tags and outputs the counts to stdout.
 * Run object `CountScenarios` to run the tool.
 */
case object CountScenarios {
  def main(args: Array[String]): Unit = {
    report(CypherTCK.allTckScenarios)
  }

  def report(scenarios: Seq[Scenario]): Unit = {
    // create individual counts to each scenario
    val individualCounts = scenarios.map(s => {
      // total
      val totalMap = Map[CountCategory,Int](Total -> 1)
      // category
      def mapToCountCategories(categories: List[String], parent: CountCategory): List[CountCategory] = categories match {
        case Nil => List[ScenarioCategory]()
        case category :: remainingCategories =>
          val countCategory = ScenarioCategory(category, parent.indent + 1, Some(parent))
          countCategory :: mapToCountCategories(remainingCategories, countCategory)
      }
      val countCategories = mapToCountCategories(s.categories, Total)
      val categoryMap = countCategories.map(countCategory => countCategory -> 1).toMap[CountCategory,Int]
      // feature
      val featureMap = Map[CountCategory,Int](Feature(s.featureName, countCategories.last.indent + 1, Some(countCategories.last)) -> 1)
      // tags
      val tagsMap = s.tags.map(tag => Tag(tag) -> 1).toMap[CountCategory,Int]

      totalMap ++ featureMap ++ categoryMap ++ tagsMap
    })
    // total up the counts over all scenarios
    val totalCounts = individualCounts.foldLeft(Map[CountCategory,Int]()){
      case (count, counts) =>
        (counts.keySet ++ count.keySet).map(key => key -> (counts.getOrElse(key, 0) + count.getOrElse(key, 0))).toMap
    }
    val countCategoriesByParent = totalCounts.keys.groupBy(countCategory => countCategory.parent)
    val outputs = totalCounts.keys.map(cat => cat -> {
      ("| " * cat.indent) + cat
    }).toMap
    // maxOutputLength is needed to align the counts
    val maxOutputLength = outputs.values.map(_.length).max

    // print counts to stdout as a count category tree in dept first order
    def printDepthFirst(currentCategory: CountCategory): Unit = {
      val thisOutput = outputs(currentCategory)
      println(thisOutput + (" " * (maxOutputLength-thisOutput.length)) + "   " + totalCounts.getOrElse(currentCategory, 0))
      // on each level ordered in groups of Total, ScenarioCategories, Features, Tags
      val groupedCountSubCategories = countCategoriesByParent.getOrElse(Some(currentCategory), Iterable[CountCategory]()).groupBy{
        case Total => 0
        case _:ScenarioCategory => 1
        case _:Feature => 2
        case _:Tag => 3
      }
      // within each group ordered alphabetically by name
      val groupedAndOrderedCountSubCategories = groupedCountSubCategories.toSeq.sortBy(_._1).flatMap {
        case (_, countCategories) => countCategories.toSeq.sortBy(_.name)
      }

      groupedAndOrderedCountSubCategories.foreach(printDepthFirst)
    }

    printDepthFirst(Total)
  }
}
