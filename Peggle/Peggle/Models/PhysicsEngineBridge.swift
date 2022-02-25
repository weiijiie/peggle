//
//  PhysicsEngineBridge.swift
//  Peggle

import Physics

/// Acts as a bridge between the peggle game engine and the physics engine. In charge of
/// mapping the coordinates between the two, and keeping track of the rigid bodies added
/// and removed.
class PhysicsEngineBridge {

    let world: World<SpatialHash<RigidBody>, ImpulseCollisionResolver>

    private let mapper: CoordinateMapper

    private(set) var ballRigidBody: RigidBody?

    private(set) var pegIdsToRigidBody: [Peg.ID: RigidBody] = [:]

    private(set) var explosionIdsToRigidBody: [Explosion.ID: RigidBody] = [:]

    init(
        world: World<SpatialHash<RigidBody>, ImpulseCollisionResolver>,
        coordinateMapper: CoordinateMapper = IdentityCoordinateMapper()
    ) {
        self.world = world
        self.mapper = coordinateMapper
    }

    func addBall(
        _ ball: Ball,
        initialVelocity: Vector2D,
        onUpdate: @escaping World.UpdateCallback
    ) {
        let rigidBody = mapper.localToExternal(
            rigidBody: ball.makeRigidBody(initialVelocity: initialVelocity)
        )
        ballRigidBody = rigidBody

        world.addRigidBody(
            rigidBody,
            onUpdate: { body in
                onUpdate(self.mapper.externalToLocal(rigidBody: body))
            }
        )
    }

    func removeBall() {
        guard let rigidBody = ballRigidBody else {
            return
        }

        ballRigidBody = nil
        world.removeRigidBody(rigidBody)
    }

    func addPeg(_ peg: Peg, onCollide: @escaping World.CollisionCallback) {
        let rigidBody = mapper.localToExternal(
            rigidBody: peg.makeRigidBody()
        )
        pegIdsToRigidBody[peg.id] = rigidBody

        world.addRigidBody(rigidBody, onCollide: { collision in
            onCollide(self.externalToLocal(collision: collision))
        })

    }

    func removePeg(_ peg: Peg) {
        guard let rigidBody = pegIdsToRigidBody[peg.id] else {
            return
        }
        world.removeRigidBody(rigidBody)
        pegIdsToRigidBody.removeValue(forKey: peg.id)
    }

    func addBucket(
        _ bucket: Bucket,
        onUpdate: @escaping World.UpdateCallback,
        onCollideWithInside: @escaping World.CollisionCallback
    ) {
        let (leftEdge, rightEdge, inside) = bucket.makeRigidBodies()

        world.addRigidBody(mapper.localToExternal(rigidBody: leftEdge))
        world.addRigidBody(mapper.localToExternal(rigidBody: rightEdge))

        world.addRigidBody(mapper.localToExternal(rigidBody: inside)) { body in
            onUpdate(self.mapper.externalToLocal(rigidBody: body))
        } onCollide: { collision in
            onCollideWithInside(self.externalToLocal(collision: collision))
        }
    }

    func addExplosion(_ explosion: Explosion, onUpdate: @escaping World.UpdateCallback) {
        let rigidBody = mapper.localToExternal(rigidBody: explosion.makeRigidBody())

        explosionIdsToRigidBody[explosion.id] = rigidBody

        world.addRigidBody(rigidBody) { body in
            onUpdate(self.mapper.externalToLocal(rigidBody: body))
        }
    }

    func removeExplosion(_ explosion: Explosion) {
        guard let rigidBody = explosionIdsToRigidBody[explosion.id] else {
            return
        }
        world.removeRigidBody(rigidBody)
        explosionIdsToRigidBody.removeValue(forKey: explosion.id)
    }

    func isBallOrExplosionCollision(
        _ collision: Collision
    ) -> (isBallCollision: Bool, isExplosionCollision: Bool) {
        var isBallCollision = false
        var isExplosionCollision = false

        if let body = ballRigidBody, collision.involvesBody(body) {
            isBallCollision = true
        }

        if explosionIdsToRigidBody.values.contains(where: {
            collision.involvesBody($0)
        }) {
            isExplosionCollision = true
        }

        return (isBallCollision, isExplosionCollision)
    }

    private func externalToLocal(collision: Collision) -> Collision {
        let body1 = self.mapper.externalToLocal(rigidBody: collision.body1)
        let body2 = self.mapper.externalToLocal(rigidBody: collision.body2)

        return Collision(body1: body1, body2: body2, info: collision.info)
    }
}
