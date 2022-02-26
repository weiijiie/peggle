//
//  Polygon.swift

/// A polygon, represented as its set of points. The points must sorted in clockwise order.
struct Polygon {
    let points: [Point]

    init(points: [Point]) {
        self.points = points
    }

    var numSides: Int {
        points.count
    }

    /// Returns the unit normals for each of the sides of the polygon
    func getUnitNormals() -> [Vector2D] {
        if points.isEmpty {
            return []
        }

        var edges: [Vector2D] = []

        for i in points.indices {
            if i + 1 < points.count {
                let edge = Vector2D.from(points[i], to: points[i + 1])
                edges.append(edge)
            } else {
                let edge = Vector2D.from(points[i], to: points[0])
                edges.append(edge)
            }
        }

        return edges.map { Vector2D(x: -$0.y, y: $0.x).unitVector }
    }

    /// Returns the min and max values of the polygon when projected onto the given `axis`
    func getMinMaxAlongAxis(axis: Vector2D) -> (min: Double, max: Double)? {
        if points.isEmpty {
            return nil
        }

        let projections = points.map {
            Vector2D.dotProduct(Vector2D(x: $0.x, y: $0.y), axis)
        }

        // we know that projections is non empty as polygen was checked to be not empty.
        // thus, min and max will never return nil
        return (projections.min()!, projections.max()!)
    }

    /// Checks for collisions between the two given polygons by using the Separating Axis Theorem (SAT).
    /// The basic idea is that two objects are colliding if and only if all the projections on each of the axes
    /// parallel to their edges overlap. More in-depth explanations can be easily found online.
    ///
    /// - Returns:
    ///   `nil` if there is no collision, and a `CollisionInfo` struct if there is one. The
    ///   penetration normal is in the direction of the minimum distance that `polygon2` needs
    ///   to  be moved to stop colliding with `polygon1`.
    static func SAT(polygon1: Polygon, polygon2: Polygon) -> CollisionInfo? {
        if polygon1.points.isEmpty || polygon2.points.isEmpty {
            return nil
        }

        let normals = polygon1.getUnitNormals() + polygon2.getUnitNormals()

        let mtvs = normals.compactMap { normal -> (mtv: Double, normal: Vector2D)? in
            let mtv = getMTVAlongNormal(polygon1: polygon1, polygon2: polygon2, normal: normal)
            guard let mtv = mtv else {
                return nil
            }

            return (mtv, normal)
        }

        // SAT checks that there is an overlap on all axes, and there is 1 axis per side
        // of each polygon. thus, if the overlap count is less than the total number
        // of sides on both polygons, there is no overlap on some axes
        if mtvs.count < (polygon1.numSides + polygon2.numSides) {
            return nil
        }

        // again, we know that mtvs is not empty, so `min()` won't return nil
        let (smallestMTV, normal) = mtvs.min { $0.mtv.magnitude < $1.mtv.magnitude }!

        if smallestMTV >= 0 {
            return CollisionInfo(
                penetrationDistance: smallestMTV.magnitude,
                penetrationNormal: normal
            )
        } else {
            // flip the normal if the mtv is negative
            return CollisionInfo(
                penetrationDistance: smallestMTV.magnitude,
                penetrationNormal: -normal
            )
        }
    }

    /// Returns the mimimum translation vector (MTV) for the two polygons along the given `normal`.
    /// MTV is defined as the shortest distance that the two polygons can be moved in order to no longer
    /// be colliding with each other. Specifically, this function returns `x` such that `polygon2` should
    /// be moved `x` distance along the normal to stop colliding with `polygon1`
    ///
    /// - Returns: The MTV is there is a collision between the two polygons, and `nil` otherwise.
    static func getMTVAlongNormal(
        polygon1: Polygon,
        polygon2: Polygon,
        normal: Vector2D
    ) -> Double? {
        // we know that this won't return nil as we checked that the polygons are non-empty
        let (min1, max1) = polygon1.getMinMaxAlongAxis(axis: normal)!
        let (min2, max2) = polygon2.getMinMaxAlongAxis(axis: normal)!

        // the difference between the smaller of the maximums and the larger
        // of the minimums gives us the overlap distance.
        let overlap = min(max1, max2) - max(min1, min2)

        // if there is no overlap then the polygons are not colliding
        if overlap <= 0 {
            return nil
        }

        // the polygon on the "right" w.r.t this normal as an axis is polygon 2
        if max(max1, max2) == max2 {

            if min(min1, min2) == min1 {
                // this is the normal case of overlap, where the mtv is the overlap
                return overlap

            } else {
                // polygon 2 completely surrounds polygon 1 on this axis. thus, we need
                // to compute the mtv by adding the shorter distance from polygon 1 to
                // either the min or max of polygon 2
                let right = max2 - max1
                let left = min1 - min2

                if left < right {
                    return overlap + left
                } else {
                    // we also need to negate the mtv here, since polygon 2 needs to move
                    // towards the left.
                    return -(overlap + right)
                }
            }

        } else {
            // the polygon on the "right" w.r.t this normal is polygon 1
            if min(min1, min2) == min2 {
                // we need to negate the overlap as polygon 2 needs to be moved
                // towards the "left"
                return -overlap

            } else {
                // similar to above but polygon 1 completely surrounds polygon 2
                let right = max1 - max2
                let left = min2 - max1

                if left < right {
                    return -(overlap + left)
                } else {
                    return overlap + right
                }
            }
        }
    }
}
