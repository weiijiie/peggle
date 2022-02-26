//
//  GeometryTests.swift
//  PhysicsTests

import XCTest
@testable import Physics

// swiftlint:disable function_body_length
class GeometryTests: XCTestCase {

    struct TestCase {
        let x: Geometry
        let y: Geometry
        let collides: Bool
    }

    func testOverlaps_CircleWithCircle() throws {
        let testCases = [
            // circles overlapping
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 2),
                y: .circle(center: Point(x: 0, y: -3), radius: 2),
                collides: true
            ),
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 2),
                y: .circle(center: Point(x: 1, y: 1), radius: 2),
                collides: true
            ),
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 3),
                y: .circle(center: Point(x: -1, y: -1), radius: 0), // should work with radius of 0
                collides: true
            ),
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 2.001), // barely overlapping
                y: .circle(center: Point(x: 3, y: 4), radius: 3),
                collides: true
            ),
            // both circles' circumference touching but not overlapping
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 2),
                y: .circle(center: Point(x: 3, y: 4), radius: 3),
                collides: false
            ),
            // no overlap
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 2),
                y: .circle(center: Point(x: 10, y: 5), radius: 2),
                collides: false
            ),
            TestCase(
                x: .circle(center: Point(x: 0, y: 0), radius: 1),
                y: .circle(center: Point(x: -5, y: 3), radius: 1.5),
                collides: false
            ),
            // circles centered at same point
            TestCase(
                x: .circle(center: Point(x: 1, y: 1), radius: 1),
                y: .circle(center: Point(x: 1, y: 1), radius: 10),
                collides: true
            )
        ]

        for (n, testCase) in testCases.enumerated() {
            let collisionInfo = Geometry.collisionBetween(testCase.x, testCase.y)
            XCTAssertEqual(collisionInfo != nil, testCase.collides,
                           """
                           Case \(n), Test case = \(testCase)
                           The two circle geometries should\(testCase.collides ? " " : " not ")collide.
                           """)
        }
    }

    func testOverlaps_RectangleWithRectangle() {
        let testCases = [
            // does not overlap
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 2, height: 4),
                y: .axisAlignedRectangle(center: Point(x: 10, y: 10), width: 4, height: 6),
                collides: false
            ),
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 4, height: 20),
                y: .axisAlignedRectangle(center: Point(x: -5, y: 0), width: 2.5, height: 7),
                collides: false
            ),
            // edges touching, no overlap
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 1, y: 0), width: 2, height: 10),
                y: .axisAlignedRectangle(center: Point(x: -1, y: 0), width: 2, height: 10),
                collides: false
            ),
            // corner touching, no overlap
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 2, height: 2),
                y: .axisAlignedRectangle(center: Point(x: -3, y: -2), width: 4, height: 2),
                collides: false
            ),
            // overlaps
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 2, height: 4),
                y: .axisAlignedRectangle(center: Point(x: 2, y: 1), width: 3, height: 2),
                collides: true
            ),
            // rectangle1 in rectangle2
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 4, height: 11),
                y: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 10, height: 12),
                collides: true
            ),
            // rectangle2 in rectangle1
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: -4, y: -4), width: 10, height: 10),
                y: .axisAlignedRectangle(center: Point(x: -5, y: -5), width: 2, height: 1),
                collides: true
            ),
            // line (0 width rectangle) intersecting rectangle
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 1, y: 1), width: 0, height: 8),
                y: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 4, height: 6),
                collides: true
            )
        ]

        for (n, testCase) in testCases.enumerated() {
            let collisionInfo = Geometry.collisionBetween(testCase.x, testCase.y)
            XCTAssertEqual(collisionInfo != nil, testCase.collides,
                           """
                           Case \(n), Test case = \(testCase)
                           The two axis-aligned rectangle geometries should\(testCase.collides ? " " : " not ")overlap.
                           """)
        }
    }

    func testOverlaps_RectangleWithCircle() {
        let testCases = [
            // no overlap
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 1, y: 1), width: 4, height: 6),
                y: .circle(center: Point(x: -3, y: -3), radius: 2),
                collides: false
            ),
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 2, height: 5),
                y: .circle(center: Point(x: 5, y: 0), radius: 1),
                collides: false
            ),
            // edge touching but not overlapping
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 6, height: 10),
                y: .circle(center: Point(x: 6, y: 0), radius: 3),
                collides: false
            ),
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 4, height: 6),
                y: .circle(center: Point(x: 0, y: 8), radius: 5),
                collides: false
            ),
            // overlap around the edges
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 4, height: 5),
                y: .circle(center: Point(x: 6, y: 0), radius: 4.2),
                collides: true
            ),
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: -2), width: 3, height: 10),
                y: .circle(center: Point(x: 0, y: -10), radius: 4),
                collides: true
            ),
            // overlap around the corners
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 6, height: 8),
                // 1.5 > sqrt(2), which is the distance from the corner to the center of the circle
                y: .circle(center: Point(x: 4, y: 5), radius: 1.5),
                collides: true
            ),
            // circle in rectangle
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 0, y: 0), width: 6, height: 6),
                y: .circle(center: Point(x: 1, y: 1), radius: 1.7),
                collides: true
            ),
            // rectangle in circle
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 1, y: 1), width: 1, height: 2),
                y: .circle(center: Point(x: 1, y: 1), radius: 4),
                collides: true
            ),
            // line intersects circle
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 1, y: 1), width: 0, height: 6),
                y: .circle(center: Point(x: 0, y: 0), radius: 5),
                collides: true
            ),
            // line touches circle, does not intersect
            TestCase(
                x: .axisAlignedRectangle(center: Point(x: 2, y: 0), width: 0, height: 10),
                y: .circle(center: Point(x: 0, y: 0), radius: 2),
                collides: false
            )
        ]

        for (n, testCase) in testCases.enumerated() {
            let collisionInfo1 = Geometry.collisionBetween(testCase.x, testCase.y)
            let collisionInfo2 = Geometry.collisionBetween(testCase.y, testCase.x)

            XCTAssertEqual(collisionInfo1 != nil, testCase.collides,
                           """
                           Case \(n), Test case = \(testCase)
                           The circle and axis-aligned rectangle geometries \
                           should\(testCase.collides ? " " : " not ")collide.
                           """)

            // collision info should be the same but with a flipped normal
            XCTAssertEqual(collisionInfo1, collisionInfo2?.flipped(),
                           """
                           Case \(n), Test case = \(testCase)
                           The circle and axis-aligned rectangle geometries \
                           should give the same collision info when \
                           checked in either order.
                           """)
        }
    }
}
