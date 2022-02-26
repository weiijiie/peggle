//
//  PointTests.swift
//  PeggleTests

import XCTest
@testable import Physics

class PointTests: XCTestCase {

    func testDistanceTo() {

        struct TestCase {
            let point1: Point
            let point2: Point
            let expected: Double
        }

        let testCases = [
            TestCase(
                point1: Point(x: 0.0, y: 0.0),
                point2: Point(x: 3.0, y: 4.0),
                expected: 5.0
            ),
            TestCase(
                point1: Point(x: 1.0, y: 1.0),
                point2: Point(x: -4.0, y: -11.0),
                expected: 13.0
            ),
            TestCase(
                point1: Point(x: 1.0, y: 5.0),
                point2: Point(x: -6.0, y: -4.0),
                expected: sqrt(9 * 9 + 7 * 7)
            )
        ]

        for testCase in testCases {
            let distance = testCase.point1.distanceTo(otherPoint: testCase.point2)
            XCTAssertEqual(distance, testCase.expected, "Distance between points should be \(testCase.expected)")
        }
    }
}
