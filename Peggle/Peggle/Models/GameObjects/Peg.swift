//
//  Peg.swift
//  Peggle

import Physics

struct Peg: Equatable {

    typealias ID = Int

    let id: ID
    let center: Point
    let type: PegType
    let hitBox: Geometry

    private(set) var hasBeenHit = false
    private(set) var removed = false

    init(id: Int, blueprint: PegBlueprint) {
        self.id = id
        self.center = blueprint.center
        self.type = blueprint.type
        self.hitBox = blueprint.hitBox
    }

    mutating func hit() {
        hasBeenHit = true
    }

    mutating func remove() {
        removed = true
    }

    func makeRigidBody() -> RigidBody {
        let initialPosition = Vector2D(x: center.x, y: center.y)
        return RigidBody(
            motion: .static(position: initialPosition),
            hitBoxAt: { center, _ in hitBox.withCenter(center) }
        )
    }
}
