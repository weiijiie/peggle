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

    func testAddObstacle_ValidObstacles() {
        let peg1 = makePeg(x: 500, y: 500, radius: 10)
        let peg2 = makePeg(x: 5, y: 5, radius: 4.9)
        let block1 = makeBlock(
            a: Point(x: 100, y: 100),
            b: Point(x: 105, y: 110),
            c: Point(x: 110, y: 100)
        )

        blueprint.addObstacle(peg1)
        XCTAssertEqual(1, blueprint.obstacleBlueprints.count,
                       "Shoud have 1 obstacle in the blueprint after adding once")
        XCTAssertTrue(blueprint.obstacleBlueprints.contains { $0 == peg1 },
                      "Should contain the peg after adding it" )

        blueprint.addObstacle(peg2)
        XCTAssertEqual(2, blueprint.obstacleBlueprints.count,
                       "Shoud have 2 obstacles in the blueprint after adding twice")
        XCTAssertTrue(blueprint.obstacleBlueprints.contains { $0 == peg2 },
                      "Should contain the peg after adding it" )

        blueprint.addObstacle(block1)
        XCTAssertEqual(3, blueprint.obstacleBlueprints.count,
                       "Shoud have 3 obstacless in the blueprint after adding twice")
        XCTAssertTrue(blueprint.obstacleBlueprints.contains { $0 == block1 },
                      "Should contain the block after adding it" )
    }

    func testAddObstacle_InvalidObstacles() {
        let invalidObstacles = [
            makePeg(x: -10, y: -20, radius: 3), // completely outside
            makePeg(x: 1, y: -1, radius: 30), // overlapping corner
            makePeg(x: 50, y: 2, radius: 100), // overlapping edge
            makeBlock(
                a: Point(x: 999, y: 999),
                b: Point(x: 1_001, y: 1_001),
                c: Point(x: 1_000, y: 999)
            )
        ]

        for obstacle in invalidObstacles {
            blueprint.addObstacle(obstacle)
        }

        XCTAssertEqual(0, blueprint.obstacleBlueprints.count,
                       "Should have no pegs in blueprint after adding invalid pegs")
    }

    func testRemoveObstacle() {
        let peg = makePeg(x: 20, y: 30, radius: 6)

        blueprint.addObstacle(peg)
        XCTAssertEqual(1, blueprint.obstacleBlueprints.count,
                       "Should have 1 peg in blueprint after adding")

        blueprint.removeObstacle(peg)
        XCTAssertEqual(0, blueprint.obstacleBlueprints.count,
                       "Should have no pegs in blueprint after removing only one")
    }

    func makePeg(x: Double, y: Double, radius: Double) -> ObstacleBlueprint {
        ObstacleBlueprint.round(color: .blue, center: Point(x: x, y: y), radius: radius)
    }

    func makeBlock(a: Point, b: Point, c: Point) -> ObstacleBlueprint {
        ObstacleBlueprint.triangle(color: .blue, a: a, b: b, c: c)
    }
}
