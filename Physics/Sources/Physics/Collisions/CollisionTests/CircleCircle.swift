//
//  CircleCircle.swift

/// Returns the `CollisionInfo` between two circles, if any.
func getCircleCircleCollisionInfo(
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
