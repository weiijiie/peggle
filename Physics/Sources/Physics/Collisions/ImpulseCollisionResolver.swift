//
//  ImpulseCollisionResolver.swift
//  Physics

// swiftlint:disable line_length fallthrough no_fallthrough_only
public class ImpulseCollisionResolver: CollisionResolver {

    /// Resolves the collisions between the two bodies by applying instantaneous impulses to both
    /// bodies in opposite directions along the penetration normal. Impulses can be seen as
    /// the change in a body's momentum, which affects the body's velocity. Returns true
    /// if the bodies were updated, and false otherwise
    ///
    /// Method based on:
    /// https://gamedevelopment.tutsplus.com/tutorials/how-to-create-a-custom-2d-physics-engine-the-basics-and-impulse-resolution--gamedev-6331
    public func resolve(collision: Collision) -> Bool {
        switch (collision.body1.material, collision.body2.material) {
        // Don't resolve collisions if either material is passthrough
        case (.passthrough, _):
            fallthrough
        case (_, .passthrough):
            return false

        case let (.solid(restitution: restitution1), .solid(restitution: restitution2)):
            let body1 = collision.body1
            let body2 = collision.body2

            let relativeVelocity = body2.velocity - body1.velocity
            let velocityAlongNormal = Vector2D.dotProduct(relativeVelocity, collision.info.penetrationNormal)

            // bodies are already moving away from each other, so we do not resolve the collision
            if velocityAlongNormal > 0 {
                return false
            }

            // Taking the minimum of the coefficient of restitutions for 2 materials leads to
            // intuitive results when simulating.
            let restitution = min(restitution1, restitution2)

            let impulseMagnitude = (-(1 + restitution) * velocityAlongNormal) /
                (body1.motion.inverseMass + body2.motion.inverseMass)

            let impulse = collision.info.penetrationNormal * impulseMagnitude

            body1.applyImpulse(-impulse)
            body2.applyImpulse(impulse)
            return true
        }
    }

    public init() {}
}
