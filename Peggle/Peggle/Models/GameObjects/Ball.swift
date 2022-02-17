//
//  Ball.swift
//  Peggle

import Physics

struct Ball {
    static let DefaultMass = 10.0
    static let DefaultMaterial = Material(restitution: 0.99)

    private(set) var hitBox: Geometry

    let radius: Double
    let mass: Double
    let material: Material

    init(
        center: Point,
        radius: Double,
        mass: Double = DefaultMass,
        material: Material = DefaultMaterial
    ) {
        self.hitBox = .circle(center: center, radius: radius)
        self.radius = radius
        self.mass = mass
        self.material = material
    }

    var center: Point {
        hitBox.center
    }

    mutating func update(hitBox: Geometry) {
        self.hitBox = hitBox
    }

    static func startingPointFor(levelWidth: Double) -> Point {
        let x = levelWidth / 2
        let y = getScaledSize(
            of: Ball.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(levelWidth)
        ) / 2

        return Point(x: x, y: Double(y))
    }
}