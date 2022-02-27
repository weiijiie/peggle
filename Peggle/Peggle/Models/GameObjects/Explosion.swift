//
//  Explosion.swift
//  Peggle

import Physics
import Foundation

/// An explosion will last for `duration`, and will expand from a radius of 0 to `maxRadius`
/// in that time.
struct Explosion: Identifiable {

    static let DefaultDuration: Float = 0.4

    let id = UUID()

    let center: Point
    let initialRadius: Double
    let maxRadius: Double

    let duration: Float

    var radius: Double

    init(
        center: Point,
        initialRadius: Double,
        maxRadius: Double,
        duration: Float = Explosion.DefaultDuration
    ) {
        self.center = center
        self.initialRadius = initialRadius
        self.maxRadius = maxRadius
        self.duration = duration

        self.radius = initialRadius
    }

    var radiusRange: Double {
        maxRadius - initialRadius
    }

    /// We represent an explosion with a rigid body with high coefficient of restitution
    /// By this method, when the explosion touches another peg, it will be registered as
    /// a collision by the game engine.
    func makeRigidBody() -> RigidBody {
        RigidBody(
            motion: .static(position: Vector2D(x: center.x, y: center.y)),
            hitBoxAt: { center, elapsedTime in
                // scale the radius of the explosion linearly with the time elapsed
                let radius = getExplosionRadiusForTime(elapsedTime)
                return .circle(center: center, radius: radius)
            },
            // use a restitution over 1 to simulate the explosive force when in contact
            // with another rigid body
            material: .solid(restitution: 1.5)
        )
    }

    /// The size of an explosion increases from the minimum radius at time 0:`initialRadius`
    /// to the maximum radius at time `duration`: `maxRadius`.
    /// This function returns the appropriate radius for the given time.
    private func getExplosionRadiusForTime(_ elapsedTime: Float) -> Double {
        // beyond the min and max time values, the size of the explosion should not change
        let time = clamp(value: elapsedTime, min: 0, max: duration)

        let elapsedFraction = time / duration
        return Double(easeOutCirc(x: elapsedFraction)) * radiusRange + initialRadius
    }

    /// Easing function for the speed of the explosion's growth. More information here:
    /// https://easings.net/#easeOutCirc
    private func easeOutCirc(x: Float) -> Float {
        sqrt(1 - pow(x - 1, 2))
    }
}
