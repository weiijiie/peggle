//
//  Peg.swift
//  Peggle

import Physics
import Foundation

// TODO: change name
struct PegBlueprint {
    let type: PegType
    let hitBox: Geometry
    let center: Point

    // TODO: name TBD
    let isInteractive: Bool

    private init(type: PegType, hitBox: Geometry, isInteractive: Bool) {
        self.type = type
        self.hitBox = hitBox
        self.center = hitBox.center
        self.isInteractive = isInteractive
    }

    static func round(type: PegType, center: Point, radius: Double) -> PegBlueprint {
        let hitBox = Geometry.circle(center: center, radius: radius)
        return self.init(type: type, hitBox: hitBox, isInteractive: true)
    }

    static func triangle(
        type: PegType,
        a: Point, b: Point, c: Point
    ) -> PegBlueprint {
        let hitBox = Geometry.triangle(a, b, c)
        return self.init(type: type, hitBox: hitBox, isInteractive: false)
    }

    static func equilateralTriangle(type: PegType, center: Point, sideLength: Double) -> PegBlueprint {
        let a = Point(x: center.x, y: center.y + (sqrt(3) / 3) * sideLength)
        let b = Point(x: center.x - sideLength / 2, y: center.y - (sqrt(3) / 6) * sideLength)
        let c = Point(x: center.x + sideLength / 2, y: center.y - (sqrt(3) / 6) * sideLength)
        return PegBlueprint.triangle(type: type, a: a, b: b, c: c)
    }

    func centeredAt(point newCenter: Point) -> PegBlueprint {
        PegBlueprint(
            type: type,
            hitBox: hitBox.withCenter(newCenter),
            isInteractive: isInteractive
        )
    }
}

extension PegBlueprint: Equatable, Codable {}
