//
//  PeggleState.swift
//  Peggle

protocol PeggleState {
    var width: Double { get }
    var height: Double { get }

    var cameraOffsetY: Double { get }

    var ball: Ball? { get }
    var pegs: [Peg.ID: Peg] { get }
    var cannon: Cannon { get }
    var bucket: Bucket { get }
    var activeExplosions: [Explosion.ID: Explosion] { get }

    var ballsRemaining: Int { get }
    var status: PeggleGameStatus { get }
}
