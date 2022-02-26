//
//  SameSide.swift

/// Returns true if `p1` and `p2` are on the same side of the straight line that passes through the
/// given start and end points. The explanation is easier done through graphical means, an excellent
/// source can be found here: https://blackpawn.com/texts/pointinpoly/default.html
func sameSide(_ p1: Point, _ p2: Point, onLineFrom start: Point, to end: Point) -> Bool {
    let startToP1 = Vector2D.from(start, to: p1)
    let startToP2 = Vector2D.from(start, to: p2)

    let startToEnd = Vector2D.from(start, to: end)

    let cp1 = Vector2D.crossProduct(startToEnd, startToP1)
    let cp2 = Vector2D.crossProduct(startToEnd, startToP2)

    // The `crossProduct` function returns the signed-magnitude of the 3D cross product
    // vector perpendicular to the 2D plane.

    // If either magnitude is zero, it means one or more of the points are on the
    // line; we consider the points to be on the same side in that cse.
    if cp1 == 0 || cp2 == 0 {
        return true
    }

    // Thus, if the magnitudes have the same sign the cross products are pointing
    // in the same direction, and thus the two points are on the same side of the line.
    return cp1.sign == cp2.sign
}
