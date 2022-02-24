//
//  PowerupManager.swift
//  Peggle

class PowerupManager {

    class ActivatedPowerup {
        let powerup: Powerup
        let hitPeg: Peg

        var timeSinceActivated: Float = 0

        init(powerup: Powerup, hitPeg: Peg) {
            self.powerup = powerup
            self.hitPeg = hitPeg
        }

        func apply(to engine: PeggleGameEngine) {
            powerup.apply(to: engine, hitPeg: hitPeg)
        }

        func expired() -> Bool {
            timeSinceActivated > powerup.duration
        }
    }

    var activatedPowerups: [ActivatedPowerup] = []

    func activatePowerup(_ powerup: Powerup, hitPeg: Peg) {
        let activatedPowerup = ActivatedPowerup(powerup: powerup, hitPeg: hitPeg)
        activatedPowerups.append(activatedPowerup)
    }

    func update(dt: Float, engine: PeggleGameEngine) {
        for powerup in activatedPowerups {
            powerup.apply(to: engine)
            powerup.timeSinceActivated += dt
        }

        // remove all the expired powerups
        activatedPowerups = activatedPowerups.filter { !$0.expired() }
    }
}
