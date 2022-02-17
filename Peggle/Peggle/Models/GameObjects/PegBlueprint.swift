//
//  Peg.swift
//  Peggle

import Physics

struct PegBlueprint {
    let color: PegColor
    let hitBox: Geometry
    let center: Point

    private init(color: PegColor, hitBox: Geometry) {
        self.color = color
        self.hitBox = hitBox
        self.center = hitBox.center
    }

    static func round(color: PegColor, center: Point, radius: Double) -> PegBlueprint {
        let hitBox = Geometry.circle(center: center, radius: radius)
        return self.init(color: color, hitBox: hitBox)
    }

    func centeredAt(point newCenter: Point) -> PegBlueprint {
        PegBlueprint(color: color, hitBox: hitBox.withCenter(newCenter))
    }
}

extension PegBlueprint: Equatable, Codable {}
