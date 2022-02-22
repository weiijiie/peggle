//
//  Motion.swift
//  Peggle

public enum Motion {
    /// Static bodies are bodies that cannot have forces applied to them,
    /// ie. they have a constant velocity
    /// Static bodies are not affected by collisions of any kind.
    case `static`(position: Vector2D = Vector2D.Zero, velocity: Vector2D = Vector2D.Zero)

    case controlled(controller: MotionController)

    /// Dynamic bodies are bodies which are fully affected by dynamics,
    /// ie. forces and collisions can affect their position and velocity.
    /// The forces will be applied the next time `stepForwardBy` is called.
    case dynamic(
        position: Vector2D = Vector2D.Zero,
        velocity: Vector2D = Vector2D.Zero,
        force: Vector2D = Vector2D.Zero,
        mass: Double
    )

    public var position: Vector2D {
        switch self {
        case let .static(position, velocity: _):
            return position

        case let .controlled(controller):
            return controller.position

        case let .dynamic(position, velocity: _, force: _, mass: _):
            return position

        }
    }

    public var velocity: Vector2D {
        switch self {
        case let .static(position: _, velocity):
            return velocity

        case let .controlled(controller):
            return controller.velocity

        case let .dynamic(position: _, velocity, force: _, mass: _):
            return velocity

        }
    }

    /// Inverse mass (ie, 1/mass) is often a more useful quantity in physics engines than the actual mass.
    public var inverseMass: Double {
        switch self {
        case .static:
            // We treat static bodies as having infinite mass, thus their inverse
            // mass can be approximated as 0.
            return 0

        case .controlled:
            // Similarly controlled bodies can be treated as having infinite mass.
            return 0

        case let .dynamic(position: _, velocity: _, force: _, mass):
            return 1 / mass
        }
    }

    /// Returns the same motion type, but with its values updated by moving forwards `dt` seconds.
    /// Values are updated based on physics dynamics, ie. position is changed by adding velocity x `dt`.
    /// Also returns whether or not the values of the motion were updated in this step.
    func stepForwardBy(time dt: Float) -> (motion: Motion, updated: Bool) {
        switch self {
        case let .static(position, velocity):
            let newPosition = position + velocity * dt
            let updated = newPosition != position

            // we don't update velocity as static bodies have constant velocity
            return (
                motion: .static(position: newPosition, velocity: velocity),
                updated: updated
            )

        case let .controlled(controller):
            let newController = controller.update(dt: dt)
            return (
                motion: .controlled(controller: newController),
                updated: true
            )

        case let .dynamic(position, velocity, force, mass):
            let newPosition = position + velocity * dt
            let newVelocity = velocity + (force / mass) * dt

            let updated = newPosition != position || newVelocity != velocity

            return (
                motion: .dynamic(
                    position: newPosition,
                    velocity: newVelocity,
                    force: Vector2D.Zero, // reset the force applied after each time step
                    mass: mass
                ),
                updated: updated
            )
        }
    }

    /// Returns the same motion type with the force given applied. If the motion type does not support
    /// applied forces, returns `self` unchanged. The force will be applied over the duration of the
    /// next step, when `stepForwardBy` is called.
    func withAppliedForce(_ newForce: Vector2D) -> Motion {
        switch self {
        case .static:
            return self

        case .controlled:
            return self

        case let .dynamic(position, velocity, force, mass):
            return .dynamic(
                position: position,
                velocity: velocity,
                force: force + newForce,
                mass: mass
            )
        }
    }

    /// Returns the same motion type with the given gravitation acceleration applied as a force.
    /// If the motion does not support applied forces, returns `self` unchanged.
    func withAppliedGravity(_ gravity: Vector2D) -> Motion {
        switch self {
        case .static:
            return self

        case .controlled:
            return self

        case let .dynamic(position: _, velocity: _, force: _, mass):
            let weight = gravity * mass
            return self.withAppliedForce(weight)
        }
    }

    func withAppliedImpulse(_ impulse: Vector2D) -> Motion {
        switch self {
        case .static:
            return self

        case .controlled:
            return self

        case let .dynamic(position, velocity, force, mass):
            let newVelocity = velocity + impulse / mass
            return .dynamic(
                position: position,
                velocity: newVelocity,
                force: force,
                mass: mass
            )
        }
    }
}
