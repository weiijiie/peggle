//
//  RigidBody2D.swift
//  Peggle

/// RigidBody is the main object that the Physics engine simulates. It is mostly a container for
/// other physics constructs like motion and geometry, and delegates most of its logic to those
/// classes.
public class RigidBody: CustomStringConvertible {

    public private(set) var motion: Motion
    public private(set) var hitBox: Geometry

    private let hitBoxAt: (_ center: Point) -> Geometry
    public let material: Material

    /// Initializes a rigid body with given motion, hitbox, and material. The hitbox paramter is actually
    /// a closure that takes in the current center of the `RigidBody`, and returns the hitbox centered
    /// at that point. This allows the hitbox to move along with the object's motion.
    public init(
        motion: Motion,
        hitBoxAt: @escaping (_ center: Point) -> Geometry,
        material: Material = Materials.PerfectlyElasticSolid
    ) {
        self.motion = motion
        self.hitBoxAt = hitBoxAt
        self.hitBox = hitBoxAt(Point(x: motion.position.x, y: motion.position.y))
        self.material = material
    }

    public var position: Vector2D {
        motion.position
    }

    public var velocity: Vector2D {
        motion.velocity
    }

    /// Advances the motion of the rigid body by a step of the given time interval `dt`.
    /// Returns true if the body's motion was updated, and false otherwise
    func stepForwardBy(time dt: Float) -> Bool {
        let (motion: newMotion, updated) = motion.stepForwardBy(time: dt)

        motion = newMotion
        if updated {
            hitBox = hitBoxAt(Point(x: motion.position.x, y: motion.position.y))
        }

        return updated
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

    public var description: String {
        """
        RigidBody(
            position: \(position),
            velocity: \(velocity),
            hitBox: \(hitBox),
            material: \(material)
        }
        """
    }
}
