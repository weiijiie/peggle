//
//  World.swift

/// Arbitrarily large double to use as a constant for some values in `World`
let MaxDouble: Double = 1_000_000_000_000

/// `World` is the top-level class where the physics simulation is run. `RigidBody`s can be added to the world,
/// and calling `update(dt)` will cause the world to step forward by a tick of duration dt. The world uses a two
/// dimensional coordinate system, where gravity acts in the negative-y direction.
///
/// The world supports:
/// - Can have infinite size (no boundaries)
/// - Can have any of left, right, bottom and top boundaries
/// - Adding and simulating rigid bodies
/// - Collision detection between rigid bodies, with callbacks on collision
/// - Collision resolution with coefficients of restitution
/// - Gravity
///
/// The world *does not* support:
/// - Rotational and angular movement
/// - Friction
/// - Drag
/// - Non-rigid bodies that can be compressed/deformed
public class World<
    TCollisionDetector: BroadPhaseCollisionDetector,
    TCollisionResolver: CollisionResolver
> where TCollisionDetector.Object == RigidBody {

    public typealias UpdateCallback = (RigidBody) -> Void
    public typealias CollisionCallback = (Collision) -> Void

    public let gravity = Vector2D(y: -9.81)

    public private(set) var minX: Double?
    public private(set) var maxX: Double?

    public private(set) var minY: Double?
    public private(set) var maxY: Double?

    public private(set) var boundaries: [RigidBody] = []
    public private(set) var rigidBodies: [RigidBody.ID: RigidBody] = [:]

    private var updateCallbacks: [RigidBody.ID: UpdateCallback] = [:]
    private var collisionCallbacks: [RigidBody.ID: CollisionCallback] = [:]

    private var broadPhaseCollisionDetector: TCollisionDetector
    private var collisionResolver: TCollisionResolver

    public init(
        broadPhaseCollisionDetector: TCollisionDetector,
        collisionResolver: TCollisionResolver,
        minX: Double? = nil,
        maxX: Double? = nil,
        minY: Double? = nil,
        maxY: Double? = nil
    ) {
        self.broadPhaseCollisionDetector = broadPhaseCollisionDetector
        self.collisionResolver = collisionResolver

        self.minX = minX
        self.maxX = maxX

        self.minY = minY
        self.maxY = maxY

        addLeftBoundary()
        addRightBoundary()
        addBottomBoundary()
        addTopBoundary()
    }

    /// Adds the given rigid body to the world, and registers the given callbacks that are
    /// called when the body is updated or collided with. Does nothing if the body already
    /// exists in the world.
    public func addRigidBody(
        _ body: RigidBody,
        onUpdate: UpdateCallback? = nil,
        onCollide: CollisionCallback? = nil
    ) {
        if rigidBodies[body.id] != nil {
            return
        }

        rigidBodies[body.id] = body
        broadPhaseCollisionDetector.addBroadPhaseObject(body)

        if onUpdate != nil {
            updateCallbacks[body.id] = onUpdate
        }

        if onCollide != nil {
            collisionCallbacks[body.id] = onCollide
        }
    }

    /// Removes the given rigid body from the world, along with any update or
    /// collision callbacks for the body. Does nothing if the body was not in the
    /// world.
    public func removeRigidBody(_ body: RigidBody) {
        let id = body.id

        rigidBodies.removeValue(forKey: id)
        broadPhaseCollisionDetector.removeBroadPhaseObject(body)

        updateCallbacks.removeValue(forKey: id)
        collisionCallbacks.removeValue(forKey: id)
    }

    /// Updates the state of the world by stepping forward in time `dt` seconds.
    /// In each timestep, there are roughly 4 tasks to do, in order:
    ///  1. Update the motion of every rigid body in the world.
    ///  2. Check for collisions between the rigid bodies.
    ///    This can be split into 2 phases, for performance:
    ///    - Broad phase: Generate *possible* groups of collisions
    ///    - Narrow phase: Brute force each possible group to find the actual collisions
    ///  3. Resolve collisions by updating the motion of bodies such that they
    ///    move away from each other in the next time step. If the time steps are
    ///    small enough, this should result in realisitic collisions.
    ///  4. Send relevant callbacks to subscribers.
    public func update(dt: Float) {
        let updatedBodies = updateMotion(dt: dt)
        let collisions = detectCollisions()
        let resolvedCollisions = resolveCollisions(collisions)

        for updatedBody in updatedBodies {
            if let callback = updateCallbacks[updatedBody.id] {
                callback(updatedBody)
            }
        }

        for collision in resolvedCollisions {
            if let callback = collisionCallbacks[collision.body1.id] {
                callback(collision)
            }

            if let callback = collisionCallbacks[collision.body2.id] {
                callback(collision)
            }
        }
    }

    /// Updates the motion of all the rigid bodies in the world by the time step of `dt`.
    /// - Returns: All the rigid bodies that were actually updated.
    private func updateMotion(dt: Float) -> [RigidBody] {
        var updatedBodies: [RigidBody] = []

        for rigidBody in rigidBodies.values {
            rigidBody.applyGravity(gravity)
            let updated = rigidBody.stepForwardBy(time: dt)

            if updated {
                updatedBodies.append(rigidBody)
                broadPhaseCollisionDetector.updateBroadPhaseObject(rigidBody)
            }
        }

        return updatedBodies
    }

    private func detectCollisions() -> [Collision] {
        let candidateCollisionGroups = broadPhaseCollisionDetector.getCandidateCollisionGroups()
        let rigidBodyCollisions = candidateCollisionGroups.flatMap(bruteForceDetectCollisions)
        let boundaryCollisions = detectBoundaryCollisions()

        return rigidBodyCollisions + boundaryCollisions
    }

    private func bruteForceDetectCollisions(rigidBodies: [RigidBody]) -> [Collision] {
        var collisions: [Collision] = []

        for i in 0..<rigidBodies.count {
            for j in i + 1..<rigidBodies.count {
                let body1 = rigidBodies[i]
                let body2 = rigidBodies[j]

                guard let collisionInfo = Geometry.collisionBetween(body1.hitBox, body2.hitBox) else {
                    continue
                }

                let collision = Collision(body1: body1, body2: body2, info: collisionInfo)
                collisions.append(collision)
            }
        }
        return collisions
    }

    private func detectBoundaryCollisions() -> [Collision] {
        boundaries.flatMap { boundary in
            rigidBodies.values.compactMap { body in
                guard let collisionInfo = Geometry.collisionBetween(body.hitBox, boundary.hitBox) else {
                    return nil
                }

                return Collision(body1: body, body2: boundary, info: collisionInfo)
            }
        }
    }

    private func resolveCollisions(_ collisions: [Collision]) -> [Collision] {
        var resolvedCollisions: [Collision] = []

        for collision in collisions {
            let resolved = collisionResolver.resolve(collision: collision)
            if resolved {
                resolvedCollisions.append(collision)
            }
        }

        return resolvedCollisions
    }

    private func addLeftBoundary() {
        if let minX = minX {
            let leftBoundary = RigidBody(
                motion: .static(position: Vector2D(x: (-MaxDouble / 2) - minX.magnitude)),
                hitBoxAt: { center in
                    .axisAlignedRectangle(
                        center: center,
                        width: MaxDouble,
                        height: Double.infinity
                    )
                }
            )

            boundaries.append(leftBoundary)
        }
    }

    private func addRightBoundary() {
        if let maxX = maxX {
            let rightBoundary = RigidBody(
                motion: .static(position: Vector2D(x: (MaxDouble / 2) + maxX.magnitude)),
                hitBoxAt: { center in
                        .axisAlignedRectangle(
                        center: center,
                        width: MaxDouble,
                        height: Double.infinity
                    )
                }
            )

            boundaries.append(rightBoundary)
        }
    }

    private func addBottomBoundary() {
        if let minY = minY {
            let bottomBoundary = RigidBody(
                motion: .static(position: Vector2D(y: (-MaxDouble / 2) - minY.magnitude)),
                hitBoxAt: { center in
                    .axisAlignedRectangle(
                        center: center,
                        width: Double.infinity,
                        height: MaxDouble
                    )
                }
            )

            boundaries.append(bottomBoundary)
        }
    }

    private func addTopBoundary() {
        if let maxY = maxY {
            let topBoundary = RigidBody(
                motion: .static(position: Vector2D(y: (MaxDouble / 2) + maxY.magnitude)),
                hitBoxAt: { center in
                    .axisAlignedRectangle(
                        center: center,
                        width: Double.infinity,
                        height: MaxDouble
                    )
                }
            )

            boundaries.append(topBoundary)
        }
    }
}
