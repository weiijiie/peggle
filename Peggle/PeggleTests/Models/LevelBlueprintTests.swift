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

    func testAddPeg_ValidPeg() {
        let peg1 = makeRoundPeg(x: 500, y: 500, radius: 10)
        let peg2 = makeRoundPeg(x: 5, y: 5, radius: 5) // touching edges

        blueprint.addPegBlueprint(peg1)
        XCTAssertEqual(1, blueprint.pegBlueprints.count, "Shoud have 1 peg in the blueprint after adding once")
        XCTAssertTrue(blueprint.pegBlueprints.contains { $0 == peg1 }, "Should contain the peg after adding it" )

        blueprint.addPegBlueprint(peg2)
        XCTAssertEqual(2, blueprint.pegBlueprints.count, "Shoud have 2 pegs in the blueprint after adding twice")
        XCTAssertTrue(blueprint.pegBlueprints.contains { $0 == peg2 }, "Should contain the peg after adding it" )
    }

    func testAddPeg_InvalidPeg() {
        let invalidPegs = [
            makeRoundPeg(x: -10, y: -20, radius: 3), // completely outside
            makeRoundPeg(x: 1, y: -1, radius: 30), // overlapping corner
            makeRoundPeg(x: 50, y: 2, radius: 100) // overlapping edge
        ]

        for peg in invalidPegs {
            blueprint.addPegBlueprint(peg)
        }

        XCTAssertEqual(0, blueprint.pegBlueprints.count, "Should have no pegs in blueprint after adding invalid pegs")
    }

    func testRemovePeg() {
        let peg = makeRoundPeg(x: 20, y: 30, radius: 6)

        blueprint.addPegBlueprint(peg)
        XCTAssertEqual(1, blueprint.pegBlueprints.count, "Should have 1 peg in blueprint after adding")

        blueprint.removePegBlueprint(peg)
        XCTAssertEqual(0, blueprint.pegBlueprints.count, "Should have no pegs in blueprint after removing only one")
    }

    func makeRoundPeg(x: Double, y: Double, radius: Double) -> PegBlueprint {
        PegBlueprint.round(type: .blue, center: Point(x: x, y: y), radius: radius)
    }
}
