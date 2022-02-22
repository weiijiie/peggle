//
//  Collision.swift
//  Peggle

public struct Collision {
    public let body1: RigidBody
    public let body2: RigidBody
    public let info: CollisionInfo

    public func involvesBody(_ body: RigidBody) -> Bool {
        body1 === body || body2 === body
    }
}

public struct CollisionInfo: Equatable {
    public let penetrationDistance: Double
    public let penetrationNormal: Vector2D

    func flipped() -> CollisionInfo {
        CollisionInfo(
            penetrationDistance: penetrationDistance,
            penetrationNormal: -penetrationNormal
        )
    }
}
