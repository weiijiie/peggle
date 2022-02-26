//
//  Geometry.swift
//  Peggle

import Darwin

/// The `Geometry` enum handles geometric logic between different geometries in the context of a 2D coordinate grid.
/// We use an enum with associated values as a discriminated union here, instead of an inheritance tree. This allows for
/// Swift to perform exhaustiveness checks in some of the logic, which would not be possible with an inheritance-based
/// approach.
public enum Geometry {

    case circle(center: Point, radius: Double)

    // An `axisAlignedRectangle` is one where the edges of the rectangle are aligned with
    // the coordinate axes.
    case axisAlignedRectangle(center: Point, width: Double, height: Double)

    // A triangle is represented by the points of each of its vertices.
    case triangle(Point, Point, Point)

    public var width: Double {
        switch self {
        case let .circle(_, radius):
            return radius * 2

        case let .axisAlignedRectangle(_, width, _):
            return width

        case let .triangle(a, b, c):
            let minX = min(a.x, b.x, c.x)
            let maxX = max(a.x, b.x, c.x)
            return maxX - minX
        }
    }

    public var height: Double {
        switch self {
        case let .circle(_, radius):
            return radius * 2

        case let .axisAlignedRectangle(_, _, height):
            return height

        case let .triangle(a, b, c):
            let minY = min(a.y, b.y, c.y)
            let maxY = max(a.y, b.y, c.y)
            return maxY - minY
        }
    }

    public var center: Point {
        switch self {
        case let .circle(center, _):
            return center

        case let .axisAlignedRectangle(center, _, _):
            return center

        case let .triangle(a, b, c):
            let centerX = (a.x + b.x + c.x) / 3
            let centerY = (a.y + b.y + c.y) / 3
            return Point(x: centerX, y: centerY)
        }
    }

    public func withCenter(_ newCenter: Point) -> Geometry {
        switch self {
        case let .circle(_, radius):
            return .circle(center: newCenter, radius: radius)

        case let .axisAlignedRectangle(_, width, height):
            return .axisAlignedRectangle(center: newCenter, width: width, height: height)

        case let .triangle(a, b, c):
            let translation = Vector2D.from(center, to: newCenter)
            return .triangle(
                a.addVector(translation),
                b.addVector(translation),
                c.addVector(translation)
            )

        }
    }

    /// Checks if there is any any collision between the two given geometries. Edges/corners that are touching
    /// do not count as colliding.
    /// The penetration normal in the returned `CollisionInfo` struct is the unit vector pointing in the
    /// direction that `geometry2` needs to be moved so as to stop colliding with `geometry1`.
    /// 
    /// - Returns: The collision struct representng the collision if there is a collision, or `nil` otherwise
    public static func collisionBetween(_ geometry1: Geometry, _ geometry2: Geometry) -> CollisionInfo? {
        // There must be logic to check for overlaps between any given pair of geometries.
        // Thus, using a switch case over a 2-tuple of enums allows Swift to perform exhaustiveness
        // checks to ensure that all cases are accounted for.
        switch (geometry1, geometry2) {

        case let(.circle(center1, radius1),
                 .circle(center2, radius2)):

            return getCircleCircleCollisionInfo(
                center1: center1, radius1: radius1,
                center2: center2, radius2: radius2
            )

        case let (.axisAlignedRectangle(center: center1, width: width1, height: height1),
                  .axisAlignedRectangle(center: center2, width: width2, height: height2)):

            return getAARAARCollisionInfo(
                center1: center1, width1: width1, height1: height1,
                center2: center2, width2: width2, height2: height2
            )

        case let (.axisAlignedRectangle(center: rectCenter, width: width, height: height),
                  .circle(center: circleCenter, radius: radius)):

            return getAARCircleCollisionInfo(
                rectCenter: rectCenter, width: width, height: height,
                circleCenter: circleCenter, radius: radius
            )

        case let (.circle(center: circleCenter, radius: radius),
                  .axisAlignedRectangle(center: rectCenter, width: width, height: height)):

            return getAARCircleCollisionInfo(
                rectCenter: rectCenter, width: width, height: height,
                circleCenter: circleCenter, radius: radius
            )?.flipped()

        case let (.triangle(a, b, c), .triangle(x, y, z)):

            return getTriangleTriangleCollisionInfo(a: a, b: b, c: c, x: x, y: y, z: z)

        case let (.triangle(a, b, c), .circle(center, radius)):

            return getTriangleCircleCollisionInfo(
                a: a, b: b, c: c, center: center, radius: radius
            )

        case let (.circle(center, radius), .triangle(a, b, c)):

            return getTriangleCircleCollisionInfo(
                a: a, b: b, c: c, center: center, radius: radius
            )?.flipped()

        case let (.triangle(a, b, c), .axisAlignedRectangle(center, width, height)):

            return getTriangleAARCollisionInfo(
                a: a, b: b, c: c,
                center: center, width: width, height: height
            )

        case let (.axisAlignedRectangle(center, width, height), .triangle(a, b, c)):

            return getTriangleAARCollisionInfo(
                a: a, b: b, c: c,
                center: center, width: width, height: height
            )?.flipped()
        }
    }

    /// Convenience method to simply return whether or not there is an overlap between the two geometries,
    /// discarding the `CollisionInfo` result.
    public static func overlaps(_ geometry1: Geometry, _ geometry2: Geometry) -> Bool {
        collisionBetween(geometry1, geometry2) != nil
    }
}

extension Geometry: Equatable, Codable {}
