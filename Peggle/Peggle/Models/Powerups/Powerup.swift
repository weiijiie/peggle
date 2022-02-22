//
//  Powerup.swift
//  Peggle

protocol Powerup {
    // powerup name should be unique among all powerups
    var name: String { get }

    // duration that the powerup should last for, in seconds
    var duration: Float { get }

    func apply(to engine: PeggleGameEngine)
}
