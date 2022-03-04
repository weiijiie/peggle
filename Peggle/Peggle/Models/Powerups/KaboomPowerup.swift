//
//  KaboomPowerup.swift
//  Peggle

import Physics

struct KaboomPowerup: Powerup {
    let name: String = "Kaboom"

    let duration: Float = 0 // expires instantaneously

    func apply(to engine: PeggleGameEngine, hitPeg: Peg) {
        let center = hitPeg.center

        let initialRadius = getExplosionRadius(hitBox: hitPeg.hitBox, scaleFactor: 1.5)
        let maxRadius = getExplosionRadius(hitBox: hitPeg.hitBox, scaleFactor: 4)

        AudioPlayer.default.playSound(.explosion)

        let explosion = Explosion(
            center: center,
            initialRadius: initialRadius,
            maxRadius: maxRadius
        )
        engine.startExplosion(explosion)
        _ = engine.removePeg(hitPeg, force: true)
    }

    private func getExplosionRadius(hitBox: Geometry, scaleFactor: Double) -> Double {
        switch hitBox {
        case let .circle(_, radius):
            return radius * scaleFactor
        case let .axisAlignedRectangle(_, width, height):
            return (width + height) / 4 * scaleFactor
        case .triangle:
            return (hitBox.width + hitBox.height) / 4 * scaleFactor
        }
    }
}
