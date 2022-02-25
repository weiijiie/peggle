//
//  AARAAR.swift

// swiftlint:disable function_parameter_count

/// Returns the `CollisionInfo` between two axis-aligned rectangles (AAR), if any. When two
/// axis-aligned rectangles overlap, the collision normal is the normal along the face that overlaps
/// for each rectangle. It is possible that multiple faces are involved in the overlap (ie. when two
/// corners of the rectangles are overlapping. In that case, the collision normal is the normal along
/// the *axis of minimum penetration*, ie. the axis where the overlap is shorter.
func getAARAARCollisionInfo(
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
}
