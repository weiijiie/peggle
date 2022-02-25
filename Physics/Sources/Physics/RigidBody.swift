//
//  RigidBody2D.swift
//  Peggle

import Foundation

/// RigidBody is the main object that the Physics engine simulates. It is mostly a container for
/// other physics constructs like motion and geometry, and delegates most of its logic to those
/// classes.
public class RigidBody: Identifiable, CustomStringConvertible {

    public typealias HitBoxFunc = (_ center: Point, _ elapsedTime: Float) -> Geometry
    
    public let id: UUID

    public private(set) var motion: Motion
    public private(set) var hitBox: Geometry

    public let hitBoxAt: HitBoxFunc
    public let material: Material

    /// Tracks the amount of time this rigid body has been simulated
    public private(set) var elapsedTime: Float

    /// Initializes a rigid body with given motion, hitbox, and material. The hitbox paramter is actually
    /// a closure that takes in the current center of the `RigidBody`, and returns the hitbox centered
    /// at that point. This allows the hitbox to move along with the object's motion.
    public init(
        motion: Motion,
        hitBoxAt: @escaping HitBoxFunc,
        material: Material = Materials.PerfectlyElasticSolid,
        elapsedTime: Float = 0,
        id: UUID = UUID()
    ) {
        self.motion = motion
        self.hitBoxAt = hitBoxAt
        self.hitBox = hitBoxAt(Point(x: motion.position.x, y: motion.position.y), elapsedTime)
        self.material = material
        self.elapsedTime = elapsedTime
        self.id = id
    }

    public var position: Vector2D {
        motion.position
    }

    public var velocity: Vector2D {
        motion.velocity
    }

    /// Advances the motion and hitbox of the rigid body by a step of the given time interval `dt`.
    /// Returns true if the body motion was updated, and false otherwise
    func stepForwardBy(time dt: Float) -> Bool {
        elapsedTime += dt
        let (motion: newMotion, updated: motionUpdated) = motion.stepForwardBy(time: dt)

        motion = newMotion

        // update hitbox
        let newHitBox = hitBoxAt(Point(x: motion.position.x, y: motion.position.y), elapsedTime)
        let hitboxUpdated = newHitBox != hitBox

        hitBox = newHitBox

        return motionUpdated || hitboxUpdated
    }

    func applyForce(_ force: Vector2D) {
        motion = motion.withAppliedForce(force)
    }

    func applyGravity(_ gravity: Vector2D) {
        motion = motion.withAppliedGravity(gravity)
    }

    func applyImpulse(_ impulse: Vector2D) {
        motion = motion.withAppliedImpulse(impulse)
    }

    /// Instantaneously moves the rigid body to the given position, without affecting it's velocity
    func teleport(to newPosition: Vector2D) {
        switch motion {
        case let .static(_, velocity):
            motion = .static(position: newPosition, velocity: velocity)

        // controlled rigid bodies should not be able to be teleported
        case .controlled:
            return

        case let .dynamic(_, velocity, force, mass):
            motion = .dynamic(
                position: newPosition,
                velocity: velocity,
                force: force,
                mass: mass
            )
        }
    }

    public var description: String {
        """
        RigidBody(
            id: \(id),
            position: \(position),
            velocity: \(velocity),
            hitBox: \(hitBox),
            material: \(material),
            elapsedTime: \(elapsedTime)
        }
        """
    }
}
