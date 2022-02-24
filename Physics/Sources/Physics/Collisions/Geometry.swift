//
//  Geometry.swift
//  Peggle

import Darwin

// swiftlint:disable function_parameter_count line_length

/// The `Geometry` enum handles geometric logic between different geometries in the context of a 2D coordinate grid.
/// We use an enum with associated values as a discriminated union here, instead of an inheritance tree. This allows for
/// Swift to perform exhaustiveness checks in some of the logic, which would not be possible with an inheritance-based
/// approach.
public enum Geometry {

    case circle(center: Point, radius: Double)

    // An `axisAlignedRectangle` is one where the edges of the rectangle are aligned with
    // the coordinate axes.
    case axisAlignedRectangle(center: Point, width: Double, height: Double)
    
    public var width: Double {
        switch self {
        case let .circle(_, radius):
            return radius * 2
        case let .axisAlignedRectangle(_, width, _):
            return width
        }
    }
    
    public var height: Double {
        switch self {
        case let .circle(_, radius):
            return radius * 2
        case let .axisAlignedRectangle(_, _, height):
            return height
        }
    }

    public var center: Point {
        switch self {
        case let .circle(center, _):
            return center
        case let .axisAlignedRectangle(center, _, _):
            return center
        }
    }

    public func withCenter(_ newCenter: Point) -> Geometry {
        switch self {
        case let .circle(_, radius):
            return .circle(center: newCenter, radius: radius)
        case let .axisAlignedRectangle(_, width, height):
            return .axisAlignedRectangle(center: newCenter, width: width, height: height)
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

            let collisionInfo = getAARCircleCollisionInfo(
                rectCenter: rectCenter, width: width, height: height,
                circleCenter: circleCenter, radius: radius
            )

            guard let collisionInfo = collisionInfo else {
                return nil
            }

            return CollisionInfo(
                penetrationDistance: collisionInfo.penetrationDistance,
                penetrationNormal: -collisionInfo.penetrationNormal
            )
        }
    }

    /// Convenience method to simply return whether or not there is an overlap between the two geometries,
    /// discarding the `CollisionInfo` result.
    public static func overlaps(_ geometry1: Geometry, _ geometry2: Geometry) -> Bool {
        collisionBetween(geometry1, geometry2) != nil
    }

    /// Returns the `CollisionInfo` between two circles, if any.
    private static func getCircleCircleCollisionInfo(
        center1: Point, radius1: Double,
        center2: Point, radius2: Double
    ) -> CollisionInfo? {

        // To check if two circles collide, we can simply check if the total distance
        // between centers is less than the sum of the radii of the circles.
        let distBetweenCenters = center1.distanceTo(otherPoint: center2)
        let radiiSum = radius1 + radius2
        let overlaps = distBetweenCenters < radiiSum

        if !overlaps {
            return nil
        }

        if distBetweenCenters == 0 {
            // Since circles are centered on the exact same position,
            // we take the larger of the radii as the penetration distance.
            // Any penetration normal is valid, so we use an arbitrary vector.
            return CollisionInfo(
                penetrationDistance: max(radius1, radius2),
                penetrationNormal: Vector2D(x: 1, y: 0)
            )
        }

        // Otherwise, the penetration distance is the distance between centers
        // subtracted from the sum of radii (can be easily derived by drawing
        // the circles). The normal is simply the unit vector in the direction
        // from 1 center to the other.
        return CollisionInfo(
            penetrationDistance: radiiSum - distBetweenCenters,
            penetrationNormal: Vector2D.from(center1, to: center2).unitVector
        )
    }

    /// Returns the `CollisionInfo` between two axis-aligned rectangles (AAR), if any. When two
    /// axis-aligned rectangles overlap, the collision normal is the normal along the face that overlaps
    /// for each rectangle. It is possible that multiple faces are involved in the overlap (ie. when two
    /// corners of the rectangles are overlapping. In that case, the collision normal is the normal along
    /// the *axis of minimum penetration*, ie. the axis where the overlap is shorter.
    private static func getAARAARCollisionInfo(
        center1: Point, width1: Double, height1: Double,
        center2: Point, width2: Double, height2: Double
    ) -> CollisionInfo? {

        // To check if two axis-aligned rectangles overlap, we take an approach based on
        // the above circles approach. We consider the x and y axes separately. If the
        // total distance between centers along 1 axis is less than the sum of the
        // distance from the centers to the edge of each rectangle, then the two rectangles
        // overlap along that axis. If this is the case for both axes, then the two rectangles
        // must overlap.
        let distX = abs(center1.x - center2.x)
        let distY = abs(center1.y - center2.y)

        let xOverlap = (width1 + width2) / 2 - distX
        let yOverlap = (height1 + height2) / 2 - distY

        let overlapsAlongXAxis = xOverlap > 0
        let overlapsAlongYAxis = yOverlap > 0
        let overlaps = overlapsAlongXAxis && overlapsAlongYAxis

        if !overlaps {
            return nil
        }

        // Depending on which overlap along an axis is smaller, we resolve
        // collisions along that axis. The normal will then be the unit vector
        // parallel to that axis, pointing from from AAR 1 to AAR 2.
        if xOverlap < yOverlap {
            return CollisionInfo(
                penetrationDistance: xOverlap,
                penetrationNormal: Vector2D.from(center1, to: center2).xComponent.unitVector
            )
        } else {
            return CollisionInfo(
                penetrationDistance: yOverlap,
                penetrationNormal: Vector2D.from(center1, to: center2).yComponent.unitVector
            )
        }
        // TODO: consider checking the scenarios where xOverlap === yOverlap
        //       (unlikely to happen in practice)
    }

    /// Returns the `CollisionInfo` between a circle and an axis-aligned rectangle (AAR), if any.
    /// Method used inspired by:
    /// https://gamedevelopment.tutsplus.com/tutorials/how-to-create-a-custom-2d-physics-engine-the-basics-and-impulse-resolution--gamedev-6331
    private static func getAARCircleCollisionInfo(
        rectCenter: Point, width: Double, height: Double,
        circleCenter: Point, radius: Double
    ) -> CollisionInfo? {

        let (closestPoint, circleCenterInsideAAR) = getClosestPointOnAAR(
            center: rectCenter,
            width: width,
            height: height,
            to: circleCenter
        )

        let closestPointToCircleCenter = Vector2D.from(closestPoint, to: circleCenter)
        let closestPointToCircleCenterDistance = closestPointToCircleCenter.magnitude

        // If the distance from the closest point on the AAR to the circle is greater
        // than the radius of the circle, there is no way the circle can intersect the
        // AAR
        if closestPointToCircleCenterDistance >= radius && !circleCenterInsideAAR {
            return nil
        }

        // TODO: give some explanation (how?!)
        if circleCenterInsideAAR {
            return CollisionInfo(
                penetrationDistance: radius + closestPointToCircleCenterDistance,
                penetrationNormal: -closestPointToCircleCenter.unitVector
            )
        } else {
            return CollisionInfo(
                penetrationDistance: radius - closestPointToCircleCenterDistance,
                penetrationNormal: closestPointToCircleCenter.unitVector
            )
        }
    }

    /// Finds the closest point on the edge of the axis-aligned rectangle (AAR) to the given `point`.
    /// - Returns: A tuple containing the closest point and whether the given `point` was inside
    ///            or outside of the AAR.
    static func getClosestPointOnAAR(
        center: Point, width: Double, height: Double, to point: Point
    ) -> (closestPoint: Point, originalPointInsideAAR: Bool) {

        let rectMinX = center.x - width / 2
        let rectMaxX = center.x + width / 2
        let rectMinY = center.y - height / 2
        let rectMaxY = center.y + height / 2

        // Clamp the point to the bounds of the rectangle along both axes.
        // We are trying to find a point on the rectangle's edge such that
        // the distance to the point along the x and y axes are minimized.
        let clampedX = clamp(value: point.x, min: rectMinX, max: rectMaxX)
        let clampedY = clamp(value: point.y, min: rectMinY, max: rectMaxY)

        let candidate = Point(x: clampedX, y: clampedY)

        // If the clamped values are the same as the original values, it means
        // along each axis, the point's coordinate was initally between the rectangle's
        // min and max coordinate. That means that the point is inside the rectangle.
        if candidate.x == point.x && candidate.y == point.y {
            // Given the point is inside the rectangle, the closest point along the
            // rectangle is on the straight line from the point to its closest edge.
            // We get that by simply checking each of the 4 edges to find which is
            // the closest.
            let distTop = abs(candidate.y - rectMaxY)
            let distBottom = abs(candidate.y - rectMinX)
            let distRight = abs(candidate.x - rectMaxX)
            let distLeft = abs(candidate.x - rectMinX)

            let min = min(distTop, distBottom, distRight, distLeft)

            if min == distTop {
                return (Point(x: candidate.x, y: rectMaxY), true)

            } else if min == distBottom {
                return (Point(x: candidate.x, y: rectMinY), true)

            } else if min == distRight {
                return (Point(x: rectMaxX, y: candidate.y), true)

            } else {
                return (Point(x: rectMinX, y: candidate.y), true)

            }
        }

        // If the point is not in the rectangle, we already have the closest point.
        return (candidate, false)
    }
}

extension Geometry: Equatable, Codable {}
