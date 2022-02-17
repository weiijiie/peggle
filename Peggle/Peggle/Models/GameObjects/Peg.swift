//
//  Peg.swift
//  Peggle

import Physics

struct Peg {

    typealias ID = Int

    let id: ID
    let center: Point
    let color: PegColor
    let hitBox: Geometry

    private(set) var hasBeenHit = false
    private(set) var removed = false

    init(id: Int, blueprint: PegBlueprint) {
        self.id = id
        self.center = blueprint.center
        self.color = blueprint.color
        self.hitBox = blueprint.hitBox
    }

    mutating func hit() {
        hasBeenHit = true
    }

    mutating func remove() {
        removed = true
    }
}
