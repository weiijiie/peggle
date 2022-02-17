//
//  ImpulseCollisionResolver.swift
//  Physics

// swiftlint:disable line_length
public class ImpulseCollisionResolver: CollisionResolver {

    /// Resolves the collisions between the two bodies by applying instantaneous impulses to both
    /// bodies in opposite directions along the penetration normal. Impulses can be seen as
    /// the change in a body's momentum, which affects the body's velocity.
    ///
    /// Method based on:
    /// https://gamedevelopment.tutsplus.com/tutorials/how-to-create-a-custom-2d-physics-engine-the-basics-and-impulse-resolution--gamedev-6331
    public func resolve(collision: Collision) -> Bool {
        // TODO: add comments explaining
        let body1 = collision.body1
        let body2 = collision.body2

        let relativeVelocity = body2.velocity - body1.velocity
        let velocityAlongNormal = Vector2D.dotProduct(relativeVelocity, collision.info.penetrationNormal)

        // bodies are already moving away from each other, so we do not resolve the collision
        if velocityAlongNormal > 0 {
            return false
        }

        let restitution = Materials.combinedRestitutiuon(body1.material, body2.material)

        let impulseMagnitude = (-(1 + restitution) * velocityAlongNormal) /
            (body1.motion.inverseMass + body2.motion.inverseMass)

        let impulse = collision.info.penetrationNormal * impulseMagnitude

        body1.applyImpulse(-impulse)
        body2.applyImpulse(impulse)
        return true
    }

    public init() {}
}
