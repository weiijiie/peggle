//
//  Powerup.swift
//  Peggle

protocol Powerup {
    // powerup name should be unique among all powerups
    var name: String { get }

    // duration that the powerup should last for, in seconds
    var duration: Float { get }

    /// Applies the powerup to the given `PeggleGameEngine`. Is also passed
    /// the peg that waas hit as a parameter.
    func apply(to engine: PeggleGameEngine, hitPeg: Peg)
}

let AllPowerups: [Powerup] = [
    SpookyPowerup(),
    KaboomPowerup()
]
