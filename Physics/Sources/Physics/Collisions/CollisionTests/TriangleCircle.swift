//
//  TriangleCircle.swift

func getTriangleCircleCollisionInfo(
    a: Point, b: Point, c: Point,
    center: Point, radius: Double
) -> CollisionInfo? {
    let nearestPoint = nearestPointOnTriangle(to: center, a: a, b: b, c: c)

    let nearestPointToCenter = Vector2D.from(nearestPoint, to: center)
    let distFromCenter = nearestPointToCenter.magnitude

    if distFromCenter >= radius {
        return nil
    }

    // if the nearest point to the center on the triangle is the center itself,
    // that means the center is located inside the triangle
    let centerInsideTriangle = nearestPoint == center
    if centerInsideTriangle {
        return CollisionInfo(
            penetrationDistance: radius + distFromCenter,
            penetrationNormal: -nearestPointToCenter.unitVector
        )
    } else {
        return CollisionInfo(
            penetrationDistance: radius - distFromCenter,
            penetrationNormal: nearestPointToCenter.unitVector
        )
    }
}
