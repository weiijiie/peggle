//
//  Vector2DTests.swift
//  PhysicsTests

import XCTest
@testable import Physics

class Vector2DTests: XCTestCase {

    let Epsilon = 0.000_001

    func testMagnitude() {
        struct TestCase {
            var vector: Vector2D
            var expectedMagnitude: Double
        }

        let testCases = [
            TestCase(
                vector: Vector2D(x: 4, y: 3),
                expectedMagnitude: 5
            ),
            TestCase(
                vector: Vector2D(x: 1, y: 1),
                expectedMagnitude: sqrt(2)
            ),
            TestCase(
                vector: Vector2D(x: 10, y: 0),
                expectedMagnitude: 10
            ),
            TestCase(
                vector: Vector2D(x: 0, y: -12),
                expectedMagnitude: 12
            ),
            TestCase(
                vector: Vector2D(x: 0, y: 0),
                expectedMagnitude: 0
            )
        ]

        for testCase in testCases {
            let magnitude = testCase.vector.magnitude

            XCTAssertEqual(magnitude, testCase.expectedMagnitude, accuracy: Epsilon,
                           "Expected magnitude to be \(testCase.expectedMagnitude), got \(magnitude)")
        }
    }

    func testUnitVector() {
        struct TestCase {
            var vector: Vector2D
            var expectedUnitVector: Vector2D
        }

        let testCases = [
            TestCase(
                vector: Vector2D(x: 10, y: 0),
                expectedUnitVector: Vector2D(x: 1, y: 0)
            ),
            TestCase(
                vector: Vector2D(x: -1, y: -1),
                expectedUnitVector: Vector2D(x: -(sqrt(2) / 2), y: -(sqrt(2) / 2))
            ),
            TestCase(
                vector: Vector2D(x: 4, y: -3),
                expectedUnitVector: Vector2D(x: 4 / 5, y: -3 / 5)
            )
        ]

        for testCase in testCases {
            let unitVector = testCase.vector.unitVector

            assertVectorsEqual(unitVector, testCase.expectedUnitVector, accuracy: Epsilon)
        }
    }

    func testDotProduct() {
        struct TestCase {
            var vector1: Vector2D
            var vector2: Vector2D
            var expected: Double
        }

        let testCases = [
            TestCase(
                vector1: Vector2D(x: -4, y: -9),
                vector2: Vector2D(x: -1, y: 2),
                expected: -14
            ),
            TestCase(
                vector1: Vector2D(x: -3, y: 4),
                vector2: Vector2D(x: 7, y: 13),
                expected: 31
            ),
            TestCase(
                vector1: Vector2D(x: 5, y: 7),
                vector2: Vector2D.Zero,
                expected: 0
            )
        ]

        for testCase in testCases {
            let dotProduct = Vector2D.dotProduct(testCase.vector1, testCase.vector2)

            XCTAssertEqual(dotProduct, testCase.expected,
                           "Expected dot product to equal \(testCase.expected), got \(dotProduct)")

            // test commutative property
            let dotProduct2 = Vector2D.dotProduct(testCase.vector2, testCase.vector1)

            XCTAssertEqual(dotProduct, dotProduct2,
                           "Expected dot product results to be the same regardless of argument order")
        }
    }

    func assertVectorsEqual(_ vector1: Vector2D, _ vector2: Vector2D, accuracy: Double) {
        XCTAssertEqual(vector1.x, vector2.x, accuracy: accuracy,
                       "Expected x-component of vectors to be equal")
        XCTAssertEqual(vector1.y, vector2.y, accuracy: accuracy,
                       "Expected x-component of vectors to be equal")
    }
}
