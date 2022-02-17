//
//  BroadPhaseObject.swift
//  Peggle

public typealias BoundingBox = (minX: Double, maxX: Double, minY: Double, maxY: Double)

/// A broad phase object can be used in a broad phase collision detection algorithm to
/// detect likely candidates for collisions. Most broad phase collision detection algorithms
/// simply require a bounding box, represented by min and max values along each axis.
public protocol BroadPhaseObject: Identifiable {
    var boundingBox: BoundingBox { get }
}
