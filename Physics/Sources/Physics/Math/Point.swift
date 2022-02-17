//
//  Point.swift
//  Peggle

import SwiftUI

public struct Point {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public func distanceTo(otherPoint: Point) -> Double {
        let xDiff = otherPoint.x - self.x
        let yDiff = otherPoint.y - self.y
        return sqrt(xDiff * xDiff + yDiff * yDiff)
    }
}

extension Point {
    public init(cgPoint: CGPoint) {
        self.x = Double(cgPoint.x)
        self.y = Double(cgPoint.y)
    }

    public func toCGPoint() -> CGPoint {
        CGPoint(x: Double(self.x), y: Double(self.y))
    }
}

extension Point: Equatable, Hashable, Codable {}
