//
//  Collision.swift
//  Peggle

public struct Collision {
    public let body1: RigidBody
    public let body2: RigidBody
    public let info: CollisionInfo
    
    public init(body1: RigidBody, body2: RigidBody, info: CollisionInfo) {
        self.body1 = body1
        self.body2 = body2
        self.info = info
    }

    public func involvesBody(_ body: RigidBody) -> Bool {
        body1.id == body.id || body2.id == body.id
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
