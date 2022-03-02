//
// PegBlueprint.swift
//  Peggle

import Physics
import Foundation

/// Represents the blueprint of a peg in the level designer
struct PegBlueprint {

    let id: UUID

    let color: PegColor
    let interactive: Bool

    let initialHitBox: Geometry
    let center: Point

    let rotation: Degrees
    let scale: Double

    private init(
        color: PegColor,
        interactive: Bool,
        hitBox: Geometry,
        rotation: Degrees = 0,
        scale: Double = 1.0,
        id: UUID = UUID()
    ) {
        self.color = color
        self.interactive = interactive
        self.initialHitBox = hitBox
        self.center = hitBox.center
        self.rotation = rotation
        self.scale = scale
        self.id = id
    }

    var hitBox: Geometry {
        initialHitBox.withRotation(rotation).scaled(scale)
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
        // swiftlint:disable line_length
        // Equation taken from:
        // https://math.stackexchange.com/questions/1344690/is-it-possible-to-find-the-vertices-of-an-equilateral-triangle-given-its-center
        let a = Point(x: center.x, y: center.y - (sqrt(3) / 3) * sideLength)
        let b = Point(x: center.x - sideLength / 2, y: center.y + (sqrt(3) / 6) * sideLength)
        let c = Point(x: center.x + sideLength / 2, y: center.y + (sqrt(3) / 6) * sideLength)

        return PegBlueprint.triangle(color: color, a: a, b: b, c: c)
    }

    func centeredAt(point newCenter: Point) -> PegBlueprint {
        PegBlueprint(
            color: color,
            interactive: interactive,
            hitBox: initialHitBox.withCenter(newCenter),
            rotation: rotation,
            scale: scale,
            id: id
        )
    }

    func withRotation(_ degrees: Degrees) -> PegBlueprint {
        PegBlueprint(
            color: color,
            interactive: interactive,
            hitBox: initialHitBox,
            rotation: degrees,
            scale: scale,
            id: id
        )
    }

    func scaled(_ scaleFactor: Double) -> PegBlueprint {
        PegBlueprint(
            color: color,
            interactive: interactive,
            hitBox: initialHitBox,
            rotation: rotation,
            scale: scaleFactor,
            id: id
        )
    }
}

extension PegBlueprint: Equatable, Codable, Identifiable {}
