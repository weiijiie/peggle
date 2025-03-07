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
