//
//  SpookyPowerup.swift
//  Peggle

import Physics

struct SpookyPowerup: Powerup {
    let name: String = "Spooky"

    let duration: Float = 8 // 8 seconds

    func apply(to engine: PeggleGameEngine) {
        if !engine.isBallOutOfBounds() {
            return
        }

        guard let ball = engine.ball else {
            return
        }

        // set the new position of the ball to be at the same x-axis,
        // but at the top of the level
        let newPosition = Point(x: ball.center.x, y: 0)
        engine.teleportBall(to: newPosition)
    }
}
