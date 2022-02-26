//
//  SATTests.swift

import XCTest
@testable import Physics

// swiftlint:disable function_body_length
class SATTests: XCTestCase {

    func testSAT() {
        struct TestCase {
            var polygon1: Polygon
            var polygon2: Polygon

            let collides: Bool
            let penetrationNormal: Vector2D?
            let penetrationDistance: Double?

            init(
                polygon1: Polygon,
                polygon2: Polygon,
                collides: Bool,
                penetrationNormal: Vector2D? = nil,
                penetrationDistance: Double? = nil
            ) {
                self.polygon1 = polygon1
                self.polygon2 = polygon2
                self.collides = collides
                self.penetrationNormal = penetrationNormal
                self.penetrationDistance = penetrationDistance
            }
        }

        let testCases = [
            // two triangles colliding
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: 0, y: 0),
                    Point(x: 3, y: 5),
                    Point(x: 6, y: 0)
                ]),
                polygon2: Polygon(points: [
                    Point(x: 0, y: 4),
                    Point(x: 3, y: -1),
                    Point(x: 6, y: 4)
                ]),
                collides: true
            ),
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: 0, y: 0),
                    Point(x: 0, y: 5),
                    Point(x: 6, y: 0)
                ]),
                polygon2: Polygon(points: [
                    Point(x: -4, y: 0),
                    Point(x: -4, y: 6),
                    Point(x: 1, y: 3)
                ]),
                collides: true,
                penetrationNormal: Vector2D(x: -1, y: 0),
                penetrationDistance: 1
            ),
            // two rectangles colliding
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: 0, y: 0),
                    Point(x: 0, y: 4),
                    Point(x: 6, y: 4),
                    Point(x: 6, y: 0)
                ]),
                polygon2: Polygon(points: [
                    Point(x: 5, y: 1),
                    Point(x: 5, y: 3),
                    Point(x: 9, y: 3),
                    Point(x: 9, y: 1)
                ]),
                collides: true,
                penetrationNormal: Vector2D(x: 1, y: 0),
                penetrationDistance: 1
            ),
            // two rectangles with one inside the other
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: 1, y: 2),
                    Point(x: 1, y: 5),
                    Point(x: 2, y: 5),
                    Point(x: 2, y: 2)
                ]),
                polygon2: Polygon(points: [
                    Point(x: 0, y: 0),
                    Point(x: 0, y: 10),
                    Point(x: 8, y: 10),
                    Point(x: 8, y: 0)
                ]),
                collides: true,
                penetrationNormal: Vector2D(x: 1, y: 0),
                penetrationDistance: 2
            ),
            // triangle and rectangle colliding
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: -1, y: 0),
                    Point(x: -1, y: 10),
                    Point(x: 5, y: 10),
                    Point(x: 5, y: 0)
                ]),
                polygon2: Polygon(points: [
                    Point(x: -3, y: 1),
                    Point(x: -3, y: 7),
                    Point(x: 0, y: 4)
                ]),
                collides: true,
                penetrationNormal: Vector2D(x: -1, y: 0),
                penetrationDistance: 1
            ),
            // two triangles touching but not colliding
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: 0, y: 0),
                    Point(x: 4, y: 8),
                    Point(x: 4, y: 1)
                ]),
                polygon2: Polygon(points: [
                    Point(x: 4, y: 1),
                    Point(x: 4, y: 7),
                    Point(x: 6, y: 4)
                ]),
                collides: false
            ),
            // triangle and rectangle not colliding
            TestCase(
                polygon1: Polygon(points: [
                    Point(x: 0, y: 0),
                    Point(x: 4, y: 8),
                    Point(x: 4, y: 1)
                ]),
                polygon2: Polygon(points: [
                    Point(x: 2, y: 9),
                    Point(x: 2, y: 11),
                    Point(x: 6, y: 11),
                    Point(x: 6, y: 9)
                ]),
                collides: false
            )
        ]

        for (idx, testCase) in testCases.enumerated() {
            let collisionInfo = Polygon.SAT(polygon1: testCase.polygon1, polygon2: testCase.polygon2)
            XCTAssertEqual(collisionInfo != nil, testCase.collides,
                           "The polygons in test case \(idx) should\(testCase.collides ? " " : " not ")collide")

            guard let info = collisionInfo else {
                return
            }

            if let penetrationNormal = testCase.penetrationNormal {
                XCTAssertEqual(
                    info.penetrationNormal,
                    penetrationNormal,
                    "Test case \(idx): expected normal \(penetrationNormal) but got \(info.penetrationNormal)"
                )
            }

            if let penetrationDistance = testCase.penetrationDistance {
                XCTAssertEqual(
                    info.penetrationDistance,
                    penetrationDistance,
                    "Test case \(idx): expected distance \(penetrationDistance) but got \(info.penetrationDistance)"
                )
            }
        }
    }
}
