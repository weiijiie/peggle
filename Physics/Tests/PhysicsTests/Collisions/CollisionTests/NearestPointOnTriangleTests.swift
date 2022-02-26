//
//  NearestPointOnTriangleTests.swift

import XCTest
@testable import Physics

// swiftlint:disable function_body_length
class NearestPointOnTriangleTests: XCTestCase {

    func testNearestPointOnTriangle() {
        struct TestCase {
            var a: Point
            var b: Point
            var c: Point

            var point: Point
            var expectedNearestPoint: Point
        }

        let testCases = [
            TestCase(
                a: Point(x: 0, y: 0),
                b: Point(x: 1, y: 2),
                c: Point(x: 2, y: 0),
                point: Point(x: 1, y: 1),
                expectedNearestPoint: Point(x: 1, y: 1)
            ),
            TestCase(
                a: Point(x: -3, y: 0),
                b: Point(x: -1, y: 1),
                c: Point(x: 3, y: 0),
                point: Point(x: -4, y: -1),
                expectedNearestPoint: Point(x: -3, y: 0)
            ),
            TestCase(
                a: Point(x: 3, y: 3),
                b: Point(x: 4.5, y: 6),
                c: Point(x: 6, y: 3),
                point: Point(x: 7, y: 8),
                expectedNearestPoint: Point(x: 4.5, y: 6)
            ),
            TestCase(
                a: Point(x: 0, y: 0),
                b: Point(x: 0, y: 5),
                c: Point(x: 4, y: 0),
                point: Point(x: 5, y: -1),
                expectedNearestPoint: Point(x: 4, y: 0)
            ),
            TestCase(
                a: Point(x: 0, y: 0),
                b: Point(x: -4, y: 3),
                c: Point(x: 4, y: 3),
                point: Point(x: 2, y: 5),
                expectedNearestPoint: Point(x: 2, y: 3)
            ),
            TestCase(
                a: Point(x: 3, y: 3),
                b: Point(x: 4.5, y: 6),
                c: Point(x: 6, y: 3),
                point: Point(x: 7, y: 8),
                expectedNearestPoint: Point(x: 4.5, y: 6)
            ),
            TestCase(
                a: Point(x: 0, y: 0),
                b: Point(x: 0, y: 6),
                c: Point(x: 6, y: 0),
                point: Point(x: 4.5, y: 3.5),
                expectedNearestPoint: Point(x: 3.5, y: 2.5)
            )
        ]

        for testCase in testCases {
            let nearestPoint = nearestPointOnTriangle(
                to: testCase.point, a: testCase.a, b: testCase.b, c: testCase.c
            )

            XCTAssertEqual(nearestPoint, testCase.expectedNearestPoint)
        }
    }
}
