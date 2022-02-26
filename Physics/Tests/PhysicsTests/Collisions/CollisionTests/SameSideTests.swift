//
//  SameSideTests.swift

import XCTest
@testable import Physics

// swiftlint:disable function_body_length
class SameSideTests: XCTestCase {

    func testSameSide() {
        struct TestCase {
            var point1: Point
            var point2: Point

            var start: Point
            var end: Point

            var isSameSide: Bool
        }

        let testCases = [
            TestCase(
                point1: Point(x: 1, y: 1),
                point2: Point(x: -1, y: 1),
                start: Point(x: 0, y: 0),
                end: Point(x: 5, y: 0),
                isSameSide: true
            ),
            TestCase(
                point1: Point(x: 1, y: 1),
                point2: Point(x: -1, y: -2),
                start: Point(x: 0, y: 0),
                end: Point(x: 5, y: 0),
                isSameSide: false
            ),
            // should return true if the first point is on the line
            TestCase(
                point1: Point(x: 1, y: 1),
                point2: Point(x: 2, y: 0),
                start: Point(x: 0, y: 0),
                end: Point(x: 5, y: 0),
                isSameSide: true
            ),
            // should return true if the second point is on the line
            TestCase(
                point1: Point(x: 2, y: 0),
                point2: Point(x: 1, y: -1),
                start: Point(x: 0, y: 0),
                end: Point(x: 5, y: 0),
                isSameSide: true
            ),
            TestCase(
                point1: Point(x: 3, y: 6),
                point2: Point(x: 3, y: 3),
                start: Point(x: 2, y: 2),
                end: Point(x: 4, y: 8),
                isSameSide: false
            ),
            TestCase(
                point1: Point(x: 3, y: 20),
                point2: Point(x: 5, y: 15),
                start: Point(x: 2, y: 2),
                end: Point(x: 4, y: 8),
                isSameSide: true
            )
        ]

        for (idx, testCase) in testCases.enumerated() {
            let sameSide = sameSide(
                testCase.point1,
                testCase.point2,
                onLineFrom: testCase.start,
                to: testCase.end
            )

            XCTAssertEqual(sameSide, testCase.isSameSide,
                           "Test case \(idx), expected: \(testCase.isSameSide) but got \(sameSide)")
        }
    }
}
