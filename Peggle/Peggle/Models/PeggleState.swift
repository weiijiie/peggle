//
//  PeggleState.swift
//  Peggle

protocol PeggleState {
    var width: Double { get }
    var height: Double { get }

    var cannon: Cannon { get }
    var ball: Ball? { get }
    var pegs: [Peg] { get }

    var ballsRemaining: Int { get }
    var status: PeggleGameStatus { get }
}
