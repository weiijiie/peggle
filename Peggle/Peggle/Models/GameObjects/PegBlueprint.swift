//
//  Peg.swift
//  Peggle

import Physics

struct PegBlueprint {
    let type: PegType
    let hitBox: Geometry
    let center: Point

    private init(type: PegType, hitBox: Geometry) {
        self.type = type
        self.hitBox = hitBox
        self.center = hitBox.center
    }

    static func round(type: PegType, center: Point, radius: Double) -> PegBlueprint {
        let hitBox = Geometry.circle(center: center, radius: radius)
        return self.init(type: type, hitBox: hitBox)
    }

    func centeredAt(point newCenter: Point) -> PegBlueprint {
        PegBlueprint(type: type, hitBox: hitBox.withCenter(newCenter))
    }
}

extension PegBlueprint: Equatable, Codable {}
