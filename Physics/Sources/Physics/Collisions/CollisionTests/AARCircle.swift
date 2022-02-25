//
//  AARCircle.swift

// swiftlint:disable line_length

/// Returns the `CollisionInfo` between a circle and an axis-aligned rectangle (AAR), if any.
/// Method used inspired by:
/// https://gamedevelopment.tutsplus.com/tutorials/how-to-create-a-custom-2d-physics-engine-the-basics-and-impulse-resolution--gamedev-6331
func getAARCircleCollisionInfo(
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
func getClosestPointOnAAR(
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
