//
//  Vector2D.swift
//  Peggle

// swiftlint:disable shorthand_operator
import Foundation

public struct Vector2D: Equatable {
    public let x: Double
    public let y: Double

    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    public var magnitude: Double {
        sqrt(x * x + y * y)
    }

    public var unitVector: Vector2D {
        if x == 0 && y == 0 {
            // This is a zero vector.
            // Since there is no defined unit vector for a zero vector,
            // we return an arbitrary unit vector.
            return Vector2D(x: 1, y: 0)
        }

        let mag = magnitude
        return Vector2D(x: x / mag, y: y / mag)
    }

    public var xComponent: Vector2D {
        Vector2D(x: x, y: 0)
    }

    public var yComponent: Vector2D {
        Vector2D(x: 0, y: y)
    }
    
    /// Returns a new `Vector2D` that is the original vector but rotated by the given degrees
    /// anti-clockwise around the origin.
    public func rotateAboutOrigin(degrees: Degrees) -> Vector2D {
        let cosDegrees = Double(cos(degrees: degrees))
        let sinDegrees = Double(sin(degrees: degrees))

        return Vector2D(
            x: x * cosDegrees - y * sinDegrees,
            y: y * cosDegrees + x * sinDegrees
        )
    }

    public static let Zero = Vector2D(x: 0, y: 0)

    public static func from(_ pointA: Point, to pointB: Point) -> Vector2D {
        Vector2D(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
    }

    public static func from(angle: Degrees, magnitude: Double) -> Vector2D {
        Vector2D(
            x: cos(degrees: Double(angle)) * magnitude,
            y: sin(degrees: Double(angle)) * magnitude
        )
    }

    // Vector addition
    public static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        Vector2D(x: left.x + right.x, y: left.y + right.y)
    }

    public static func += (left: inout Vector2D, right: Vector2D) {
        left = left + right
    }

    public static func - (left: Vector2D, right: Vector2D) -> Vector2D {
        Vector2D(x: left.x - right.x, y: left.y - right.y)
    }

    public static func -= (left: inout Vector2D, right: Vector2D) {
        left = left - right
    }

    // Negative vector, with same magnitude but opposite direction
    public static prefix func - (vector: Vector2D) -> Vector2D {
        Vector2D(x: -vector.x, y: -vector.y)
    }

    // Scalar multiplication
    public static func * (vector: Vector2D, scalar: Double) -> Vector2D {
        Vector2D(x: vector.x * scalar, y: vector.y * scalar)
    }

    public static func * (vector: Vector2D, scalar: Float) -> Vector2D {
        Vector2D(x: vector.x * Double(scalar), y: vector.y * Double(scalar))
    }

    public static func / (vector: Vector2D, scalar: Double) -> Vector2D {
        Vector2D(x: vector.x / scalar, y: vector.y / scalar)
    }

    public static func / (vector: Vector2D, scalar: Float) -> Vector2D {
        Vector2D(x: vector.x / Double(scalar), y: vector.y / Double(scalar))
    }

    public static func dotProduct(_ vector1: Vector2D, _ vector2: Vector2D) -> Double {
        vector1.x * vector2.x + vector1.y * vector2.y
    }

    /// We use the definition that the cross product of a 2D vector is the magnitude of the vector that results
    /// after a normal 3D cross product of the input vectors, treating their z-axis values as 0. This 3D cross
    /// product vector will be perpendicular to the 2D plane, and thus have a real numbered z-axis and 0 for
    /// x and y axes. The return value is the z-axis value of that vector.
    public static func crossProduct(_ vector1: Vector2D, _ vector2: Vector2D) -> Double {
        (vector1.x * vector2.y) - (vector1.y * vector2.x)
    }
}
