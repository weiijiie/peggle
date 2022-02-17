//
//  ProportionateCoordinateMapper.swift
//  Peggle

import Physics

/// Maps local coordinates to external coordinates and back in a proportionately scaled manner.
struct ProportionateCoordinateMapper: CoordinateMapper {

    let xScale: Double
    let yScale: Double

    /// External coordinates will be scaled to `scale` times the values of local coordinates.
    /// Conversly, local coordinates will be scaled to 1 / `scale` times the values of external coordinates
    init(scale: Double) {
        self.init(xScale: scale, yScale: scale)
    }

    private init(xScale: Double, yScale: Double) {
        self.xScale = xScale
        self.yScale = yScale
    }

    func localToExternal(point: Point) -> Point {
        Point(x: point.x * xScale, y: point.y * yScale)
    }

    func externalToLocal(point: Point) -> Point {
        Point(x: point.x / xScale, y: point.y / yScale)
    }

    func withFlippedXAxis() -> CoordinateMapper {
        ProportionateCoordinateMapper(xScale: -xScale, yScale: yScale)
    }

    func withFlippedYAxis() -> CoordinateMapper {
        ProportionateCoordinateMapper(xScale: xScale, yScale: -yScale)
    }
}
