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

    public static let Zero = Vector2D(x: 0, y: 0)

    public static func from(_ pointA: Point, to pointB: Point) -> Vector2D {
        Vector2D(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
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
}
