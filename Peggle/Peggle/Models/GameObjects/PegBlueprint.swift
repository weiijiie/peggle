//
// PegBlueprint.swift
//  Peggle

import Physics
import Foundation

/// Represents the blueprint of a peg in the level designer
struct PegBlueprint {

    let color: PegColor
    let interactive: Bool

    let initialHitBox: Geometry
    var hitBox: Geometry
    let center: Point

    var rotation: Degrees = 0 {
        didSet {
            hitBox = initialHitBox.withRotation(rotation)
        }
    }

    private init(color: PegColor, interactive: Bool, hitBox: Geometry) {
        self.color = color
        self.interactive = interactive
        self.initialHitBox = hitBox
        self.hitBox = hitBox
        self.center = hitBox.center
    }

    static func round(color: PegColor, center: Point, radius: Double) -> PegBlueprint {
        let hitBox = Geometry.circle(center: center, radius: radius)
        return self.init(color: color, interactive: true, hitBox: hitBox)
    }

    static func triangle(
        color: PegColor,
        a: Point, b: Point, c: Point
    ) -> PegBlueprint {
        let hitBox = Geometry.triangle(a, b, c)
        return self.init(color: color, interactive: false, hitBox: hitBox)
    }

    static func equilateralTriangle(color: PegColor, center: Point, sideLength: Double) -> PegBlueprint {
        let a = Point(x: center.x, y: center.y - (sqrt(3) / 3) * sideLength)
        let b = Point(x: center.x - sideLength / 2, y: center.y + (sqrt(3) / 6) * sideLength)
        let c = Point(x: center.x + sideLength / 2, y: center.y + (sqrt(3) / 6) * sideLength)

        return PegBlueprint.triangle(color: color, a: a, b: b, c: c)
    }

    func centeredAt(point newCenter: Point) -> PegBlueprint {
        PegBlueprint(
            color: color,
            interactive: interactive,
            hitBox: hitBox.withCenter(newCenter)
        )
    }
}

extension PegBlueprint: Equatable, Codable {}
