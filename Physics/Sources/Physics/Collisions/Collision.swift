//
//  Collision.swift
//  Peggle

public struct Collision {
    let body1: RigidBody
    let body2: RigidBody
    let info: CollisionInfo
}

public struct CollisionInfo: Equatable {
    let penetrationDistance: Double
    let penetrationNormal: Vector2D

    func flipped() -> CollisionInfo {
        CollisionInfo(
            penetrationDistance: penetrationDistance,
            penetrationNormal: -penetrationNormal
        )
    }
}
