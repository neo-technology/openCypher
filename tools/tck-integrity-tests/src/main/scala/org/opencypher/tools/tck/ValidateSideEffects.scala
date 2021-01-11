/*
 * Copyright (c) 2015-2021 "Neo Technology,"
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
package org.opencypher.tools.tck

import io.cucumber.core.gherkin.DataTableArgument
import org.opencypher.tools.tck.api.SideEffects
import org.opencypher.tools.tck.constants.TCKSideEffects
import org.scalatest.funspec.AnyFunSpecLike
import org.scalatest.matchers.should.Matchers

import scala.collection.JavaConverters._

/**
  * Validates side effects expectations. A valid side effect has one of the specified names in TCKSideEffects, and a
  * quantity that is an integer greater than zero.
  */
trait ValidateSideEffects extends AnyFunSpecLike with Matchers {

  def validateSideEffects(step: SideEffects): Unit = {
    val keys = step.expected.v.keySet
    val values = step.expected.v.values

    it("has no invalid keys") {
      import org.scalatest.enablers.Emptiness.emptinessOfGenTraversable
      (keys -- TCKSideEffects.ALL) shouldBe empty
    }

    it("has only numbers greater than zero in step parameter (or no parameter)") {
      if(step.source.getArgument != null) {
        // note this tests that principally valid zero side effects are not listed in the scenario's gherkin code
        val dataTable = step.source.getArgument.asInstanceOf[DataTableArgument].cells().asScala.map(_.asScala.toList).toList
        val map = dataTable.map { r => r.head -> r.tail.head.toInt }.toMap
        all (map.values) should be > 0
      } else {
        succeed
      }
    }

    it("has only numbers greater or equal zero, after filled with zero") {
      all (values) should be >= 0
    }
  }
}
