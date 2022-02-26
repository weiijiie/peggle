//
//  TriangleTriangle.swift

// swiftlint:disable function_parameter_count
func getTriangleTriangleCollisionInfo(
    a: Point, b: Point, c: Point,
    x: Point, y: Point, z: Point
) -> CollisionInfo? {
    let triangle1 = Polygon(points: [a, b, c])
    let triangle2 = Polygon(points: [x, y, z])

    return Polygon.SAT(polygon1: triangle1, polygon2: triangle2)
}

// /// Returns true if the given point is inside the triangle defined with vertices at points `a`, `b`, and `c`.
// /// We can check if the point and the opposite vertex of a triangle is on the same side of the line formed
// /// by the other 2 vertices. If this holds true for all three edges, then the point is inside the triangle.
// ///
// /// Method taken from: https://blackpawn.com/texts/pointinpoly/default.html
// func isPointInTriangle(point: Point, a: Point, b: Point, c: Point) -> Bool {
//    sameSide(point, a, onLineFrom: b, to: c) &&
//        sameSide(point, b, onLineFrom: a, to: c) &&
//        sameSide(point, c, onLineFrom: a, to: b)
// }
