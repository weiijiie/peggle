//
//  NearestPointOnTriangle.swift

/// Returns the closest point on a triangle to the given `point`. If `point` is
/// outside the triangle, then the returned point is along the triangle's edge. If `point`
/// is inside the triangle, then the returned point is the same as `point`.
/// The triangle is represented as the points of each of its 3 vertices.
///
/// Method taken from: https://2dengine.com/?p=intersections , using
/// Barycentric coordinates.
func nearestPointOnTriangle(
    to point: Point,
    a: Point, b: Point, c: Point
) -> Point {
    let aToB = Vector2D.from(a, to: b)
    let aToC = Vector2D.from(a, to: c)

    // Check vertex region outside a
    let aToPoint = Vector2D.from(a, to: point)

    let d1 = Vector2D.dotProduct(aToB, aToPoint)
    let d2 = Vector2D.dotProduct(aToC, aToPoint)

    if d1 <= 0 && d2 <= 0 {
        return a
    }

    // Check vertex region outside b
    let bToPoint = Vector2D.from(b, to: point)

    let d3 = Vector2D.dotProduct(aToB, bToPoint)
    let d4 = Vector2D.dotProduct(aToC, bToPoint)

    if d3 >= 0 && d4 <= d3 {
        return b
    }

    // Check edge region ab
    if d1 >= 0 && d3 <= 0 && d1 * d4 - d3 * d2 <= 0 {
        let v = d1 / (d1 - d3)
        return Point(x: a.x + aToB.x * v, y: a.y + aToB.y * v)
    }

    // Check vertex region outside c
    let cToPoint = Vector2D.from(c, to: point)

    let d5 = Vector2D.dotProduct(aToB, cToPoint)
    let d6 = Vector2D.dotProduct(aToC, cToPoint)

    if d6 >= 0 && d5 <= d6 {
        return c
    }

    // Check edge reason ac
    if d2 >= 0 && d6 <= 0 && d5 * d2 - d1 * d6 <= 0 {
        let w = d2 / (d2 - d6)
        return Point(x: a.x + aToC.x * w, y: a.y + aToC.y * w)
    }

    // check edge region bc
    if d3 * d6 - d5 * d4 <= 0 {
        let d43 = d4 - d3
        let d56 = d5 - d6

        if d43 >= 0 && d56 >= 0 {
            let w = d43 / (d43 + d56)
            return Point(x: b.x + (c.x - b.x) * w, y: b.y + (c.y - b.y) * w)
        }
    }

    // Point is already inside the triangle
    return point
}
