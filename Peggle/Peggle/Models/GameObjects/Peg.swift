//
//  Peg.swift
//  Peggle

import Physics
import Foundation
struct Peg: Equatable, Identifiable {

    let id = UUID()

    let color: PegColor

    let initialHitBox: Geometry
    let hitBox: Geometry

    let rotation: Degrees

    /// Blocks are just pegs that are not interactive
    let interactive: Bool

    private(set) var hasBeenHit = false
    private(set) var removed = false

    init(color: PegColor, hitBox: Geometry, rotation: Degrees, interactive: Bool) {
        self.color = color
        self.initialHitBox = hitBox
        self.hitBox = hitBox.withRotation(rotation)
        self.rotation = rotation
        self.interactive = interactive
    }

    var center: Point {
        hitBox.center
    }

    mutating func hit() {
        hasBeenHit = true
    }

    /// Returns true if the peg actually removed.
    mutating func remove(force: Bool = false) -> Bool {
        // only remove if this is an interactive peg, or it is a force removal
        if !(force || interactive) {
            return false
        }

        removed = true
        return true
    }

    func isWinCondition() -> Bool {
        if !interactive {
            return false
        }

        switch color {
        case .blue:
            return false
        case .orange:
            return true
        case .green:
            return false
        }
    }

    func isPowerup() -> Bool {
        if !interactive {
            return false
        }

        switch color {
        case .blue:
            return false
        case .orange:
            return false
        case .green:
            return true
        }
    }

    func makeRigidBody() -> RigidBody {
        let initialPosition = Vector2D(x: center.x, y: center.y)
        return RigidBody(
            motion: .static(position: initialPosition),
            hitBoxAt: { center, _ in hitBox.withCenter(center) }
        )
    }
}
