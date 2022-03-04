//
//  LevelBlueprintTests.swift
//  PeggleTests

import XCTest
import Physics
@testable import Peggle

class LevelBlueprintTests: XCTestCase {

    var blueprint: LevelBlueprint!

    override func setUpWithError() throws {
        blueprint = LevelBlueprint(width: 1_000, height: 1_000)
        try super.setUpWithError()
    }

    func testAddPeg_ValidPegs() {
        let peg1 = makeRoundPeg(x: 500, y: 500, radius: 10)
        let peg2 = makeRoundPeg(x: 5, y: 5, radius: 4.9)
        let block1 = makeTriangularPeg(
            a: Point(x: 100, y: 100),
            b: Point(x: 105, y: 110),
            c: Point(x: 110, y: 100)
        )

        blueprint.addPeg(peg1)
        XCTAssertEqual(1, blueprint.pegBlueprints.count,
                       "Shoud have 1 obstacle in the blueprint after adding once")
        XCTAssertTrue(blueprint.pegBlueprints.values.contains { $0 == peg1 },
                      "Should contain the peg after adding it" )

        blueprint.addPeg(peg2)
        XCTAssertEqual(2, blueprint.pegBlueprints.count,
                       "Shoud have 2 obstacles in the blueprint after adding twice")
        XCTAssertTrue(blueprint.pegBlueprints.values.contains { $0 == peg2 },
                      "Should contain the peg after adding it" )

        blueprint.addPeg(block1)
        XCTAssertEqual(3, blueprint.pegBlueprints.count,
                       "Shoud have 3 obstacless in the blueprint after adding twice")
        XCTAssertTrue(blueprint.pegBlueprints.values.contains { $0 == block1 },
                      "Should contain the block after adding it" )
    }

    func testAddPeg_InvalidPegs() {
        let invalidObstacles = [
            makeRoundPeg(x: -10, y: -20, radius: 3), // completely outside
            makeRoundPeg(x: 1, y: -1, radius: 30), // overlapping corner
            makeRoundPeg(x: 50, y: 2, radius: 100), // overlapping edge
            makeTriangularPeg(
                a: Point(x: 999, y: 999),
                b: Point(x: 1_001, y: 1_001),
                c: Point(x: 1_000, y: 999)
            )
        ]

        for obstacle in invalidObstacles {
            blueprint.addPeg(obstacle)
        }

        XCTAssertEqual(0, blueprint.pegBlueprints.count,
                       "Should have no pegs in blueprint after adding invalid pegs")
    }

    func testRemovePeg() {
        let peg = makeRoundPeg(x: 20, y: 30, radius: 6)

        blueprint.addPeg(peg)
        XCTAssertEqual(1, blueprint.pegBlueprints.count,
                       "Should have 1 peg in blueprint after adding")

        blueprint.removePeg(peg)
        XCTAssertEqual(0, blueprint.pegBlueprints.count,
                       "Should have no pegs in blueprint after removing only one")
    }

    func makeRoundPeg(x: Double, y: Double, radius: Double) -> PegBlueprint {
        PegBlueprint.round(color: .blue, center: Point(x: x, y: y), radius: radius)
    }

    func makeTriangularPeg(a: Point, b: Point, c: Point) -> PegBlueprint {
        PegBlueprint.triangle(color: .blue, a: a, b: b, c: c)
    }
}
