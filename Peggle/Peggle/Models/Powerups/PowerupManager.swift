//
//  PowerupManager.swift
//  Peggle

class PowerupManager {

    class ActivatedPowerup {
        let powerup: Powerup
        var timeSinceActivated: Float = 0

        init(powerup: Powerup) {
            self.powerup = powerup
        }

        func apply(to engine: PeggleGameEngine) {
            powerup.apply(to: engine)
        }

        func expired() -> Bool {
            timeSinceActivated > powerup.duration
        }
    }

    var activatedPowerups: [ActivatedPowerup] = []

    func activatePowerup(_ powerup: Powerup) {
        let activatedPowerup = ActivatedPowerup(powerup: powerup)
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
