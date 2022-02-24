//
//  Explosion.swift
//  Peggle

import Physics

/// An explosion will last for `duration`, and will expand from a radius of 0 to `maxRadius`
/// in that time.
struct Explosion {

    static let DefaultDuration: Float = 0.3

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
                let radius = min(maxRadius, Double(elapsedTime / duration) * radiusRange + initialRadius)
                return .circle(center: center, radius: radius)
            },
            // use a restitution over 1 to simulate the explosive force when in contact
            // with another rigid body
            material: .solid(restitution: 1.7)
        )
    }

    var key: Key {
        Key(
            center: center,
            initialRadius: initialRadius,
            maxRadius: maxRadius,
            duration: duration
        )
    }

    // since explosions need to be added to a dictionary, we make a hashable key out
    // of the immutable properties of an explosion. since no 2 explosions can have the
    // same center, this key can uniquely identify an explosion
    struct Key: Hashable {
        let center: Point
        let initialRadius: Double
        let maxRadius: Double
        let duration: Float
    }
}
