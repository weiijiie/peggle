//
//  TriangleAAR.swift

// swiftlint:disable function_parameter_count
func getTriangleAARCollisionInfo(
    a: Point, b: Point, c: Point,
    center: Point, width: Double, height: Double
) -> CollisionInfo? {

    let triangle = Polygon(points: [a, b, c])

    let halfWidth = width / 2
    let halfHeight = height / 2

    let minX = center.x - halfWidth
    let maxX = center.x + halfWidth

    let minY = center.y - halfHeight
    let maxY = center.y + halfHeight

    let rectangle = Polygon(points: [
        Point(x: minX, y: minY),
        Point(x: minX, y: maxY),
        Point(x: maxX, y: maxY),
        Point(x: maxX, y: minY)
    ])

    return Polygon.SAT(polygon1: triangle, polygon2: rectangle)
}
