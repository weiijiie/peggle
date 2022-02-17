//
//  CoordinateMapper.swift
//  Peggle

import Physics

/// Defines how to map coordinates from one coordinate system to another.
protocol CoordinateMapper {
    func localToExternal(point: Point) -> Point
    func externalToLocal(point: Point) -> Point
}

/// Default convenience methods. Only the above methods need to be implemented,
/// and all implementors get the methods below for free.
extension CoordinateMapper {
    // x coordinate only
    func localToExternal(x: Double) -> Double {
        localToExternal(point: Point(x: x, y: 0)).x
    }

    func externalToLocal(x: Double) -> Double {
        externalToLocal(point: Point(x: x, y: 0)).x
    }

    // y coordinate only
    func localToExternal(y: Double) -> Double {
        localToExternal(point: Point(x: 0, y: y)).y
    }

    func externalToLocal(y: Double) -> Double {
        externalToLocal(point: Point(x: 0, y: y)).y
    }

    // vectors
    func localToExternal(vector: Vector2D) -> Vector2D {
        let point = localToExternal(point: Point(x: vector.x, y: vector.y))
        return Vector2D(x: point.x, y: point.y)
    }

    func externalToLocal(vector: Vector2D) -> Vector2D {
        let point = externalToLocal(point: Point(x: vector.x, y: vector.y))
        return Vector2D(x: point.x, y: point.y)
    }

    // geometries
    func localToExternal(geometry: Geometry) -> Geometry {
        switch geometry {
        case let .circle(center, radius):
            return .circle(
                center: localToExternal(point: center),
                radius: localToExternal(x: radius).magnitude
            )
        case let .axisAlignedRectangle(center, width, height):
            return .axisAlignedRectangle(
                center: localToExternal(point: center),
                width: localToExternal(x: width),
                height: localToExternal(y: height)
            )
        }
    }

    func externalToLocal(geometry: Geometry) -> Geometry {
        switch geometry {
        case let .circle(center, radius):
            return .circle(
                center: externalToLocal(point: center),
                radius: externalToLocal(x: radius).magnitude
            )
        case let .axisAlignedRectangle(center, width, height):
            return .axisAlignedRectangle(
                center: externalToLocal(point: center),
                width: externalToLocal(x: width).magnitude,
                height: externalToLocal(y: height).magnitude
            )
        }
    }
}

struct IdentityCoordinateMapper: CoordinateMapper {
    func localToExternal(point: Point) -> Point {
        point
    }

    func externalToLocal(point: Point) -> Point {
        point
    }
}
