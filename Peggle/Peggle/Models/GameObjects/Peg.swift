//
//  Peg.swift
//  Peggle

import Physics
import Foundation

struct Peg: Equatable, Identifiable {

    let id = UUID()

    let center: Point
    let type: PegType
    let hitBox: Geometry

    private(set) var hasBeenHit = false
    private(set) var removed = false

    init(blueprint: PegBlueprint) {
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
