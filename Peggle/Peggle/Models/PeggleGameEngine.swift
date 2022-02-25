//
//  PeggleGameEngine.swift
//  Peggle

import Foundation
import Physics

class PeggleGameEngine: PeggleState {

    static let DefaultBallStartingSpeed = 450.0
    static let SpatialHashCellSize = 10.0
    static let DefaultNumStartingBalls = 5

    let width: Double
    let height: Double

    // The below 4 coordinates are relative to the coordinate system
    // used by the physics engine. They are used to simplify game logic
    // checks.
    private let minX: Double
    private let maxX: Double

    // Balls that fall below `minY` are considered "out of bounds"
    private let minY: Double
    private let maxY: Double

//    private let world: World<SpatialHash<RigidBody>, ImpulseCollisionResolver>

    private let mapper: CoordinateMapper
    private var onUpdateCallback: ((PeggleState) -> Void)?

    private(set) var pegs: [Peg.ID: Peg] = [:] {
        willSet { onUpdateCallback?(self) }
    }

    private(set) var ball: Ball? {
        willSet { onUpdateCallback?(self) }
    }

    private(set) var cannon: Cannon {
        willSet { onUpdateCallback?(self) }
    }

    private(set) var bucket: Bucket {
        willSet { onUpdateCallback?(self) }
    }

    private(set) var activeExplosions: [Explosion.ID: Explosion] = [:] {
        willSet { onUpdateCallback?(self) }
    }

    private(set) var ballsRemaining = PeggleGameEngine.DefaultNumStartingBalls {
        willSet { onUpdateCallback?(self) }
    }

    private var obtainedBucketBonus = false

    private(set) var status = PeggleGameStatus.ongoing {
        willSet { onUpdateCallback?(self) }
    }

    private(set) var winConditions: WinConditions
    private(set) var loseConditions: LoseConditions

    private(set) var powerupManager: PowerupManager
    private(set) var selectedPowerup: Powerup

    private var elapsedTime: Float = 0
    private var lastNewPegCollisionTime: Float = 0

    private var bridge: PhysicsEngineBridge

    /// Initializes the Peggle game engine based on the given level blueprint. To ensure
    /// the game engine can work with multiple coordinate systems, clients are also required
    /// to pass in a coordinate mapper, which maps from the client's local coordiate system
    /// to the external coordinate system that the Peggle game engine will use. All the values
    /// exposed to external clients via the Peggle game engine will then be in the client's local
    /// coordinate system.
    ///
    /// `maxX` and `maxY`, ie. the top-right point of the game in their coordinate
    /// system, is also required, to ensure the mapping of dimensions can be done correctly.
    ///
    /// An `onUpdate` method can also be passed in, which will be called whenever any of
    /// the game objects receive updates.
    init(
        levelBlueprint: LevelBlueprint,
        maxX: Double,
        maxY: Double,
        powerupManager: PowerupManager,
        selectedPowerup: Powerup,
        coordinateMapper: CoordinateMapper = IdentityCoordinateMapper(),
        onUpdate: ((PeggleState) -> Void)? = nil,
        winConditions: WinConditions = [],
        loseConditions: LoseConditions = []
    ) {
        self.width = levelBlueprint.width
        self.height = levelBlueprint.height

        self.mapper = coordinateMapper

        self.minX = mapper.localToExternal(x: maxX) - mapper.localToExternal(x: width).magnitude
        self.maxX = mapper.localToExternal(x: maxX)

        self.minY = mapper.localToExternal(y: maxY) - mapper.localToExternal(y: height).magnitude
        self.maxY = mapper.localToExternal(y: maxY)

        self.onUpdateCallback = onUpdate

        self.winConditions = winConditions
        self.loseConditions = loseConditions
        self.powerupManager = powerupManager
        self.selectedPowerup = selectedPowerup

        let world = World(
            broadPhaseCollisionDetector: SpatialHash(cellSize: PeggleGameEngine.SpatialHashCellSize),
            collisionResolver: ImpulseCollisionResolver(),
            minX: self.minX,
            maxX: self.maxX,
            maxY: self.maxY
        )

        self.bridge = PhysicsEngineBridge(world: world, coordinateMapper: mapper)

        self.cannon = Cannon(forLevelWidth: levelBlueprint.width)
        self.bucket = Bucket(forLevelWidth: levelBlueprint.width, forLevelHeight: levelBlueprint.height)

        initializeBucket()
        initializePegs(levelBlueprint: levelBlueprint)
        onUpdate?(self)
    }

    /// Fires the cannon, and adds a ball that has been "fired" to the default location for the balls
    /// (top-center of the game).
    ///
    /// The ball will be fired downwards with the given angle and speed.
    /// The angle must be between 0 and 180 degrees, with 0 corresponding to firing the ball parallel
    /// to the x-axis towards the right, and 180 corresponding to firing the ball parallel to the x-axis
    /// towards the left. If the angle is not between 0 and 180, the ball is not fired.
    ///
    /// - Returns: `true` if the ball was fired, and `false` otherwise.
    func fireBallWith(
        angle: Degrees,
        speed: Double = PeggleGameEngine.DefaultBallStartingSpeed
    ) -> Bool {
        guard angle >= 0 && angle <= 180 else {
            return false
        }

        guard status == .ongoing && ballsRemaining > 0 else {
            return false
        }

        cannon.fire()
        ballsRemaining -= 1

        let velocity = Vector2D.from(angle: angle, magnitude: speed)
        let startingPos = Ball.startingPointFor(levelWidth: width)

        let radius = getScaledSize(
            of: Ball.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(width)
        ) / 2

        initializeBall(position: startingPos, velocity: velocity, radius: radius)
        return true
    }

    /// Updates the Peggle game by stepping forward with duration `dt`.
    /// The function does nothing once the game has either been won or lost.
    func update(dt: Float) {
        guard status == .ongoing else {
            return
        }

        elapsedTime += dt
        bridge.world.update(dt: dt)

        // the cannon's rotation is not handled by the physics engine, so
        // we handle it separately
        cannon.stepForwardBy(dt: dt)

        // let the powerups apply their effects
        powerupManager.update(dt: dt, engine: self)

        // after each update, check if ball is out of bounds
        if self.isBallOutOfBounds() {
            self.handleBallOutOfBounds()
        }

        let newStatus = PeggleGameStatus.getStatusFor(
            state: self,
            winConditions: winConditions,
            loseConditions: loseConditions
        )

        if status != newStatus {
            status = newStatus
        }

        checkIfBallStuckAndResolve()
    }

    func isBallOutOfBounds() -> Bool {
        guard let ball = ball else {
            return false
        }

        let ballY = mapper.localToExternal(y: ball.center.y)
        let ballRadius = mapper.localToExternal(y: ball.radius).magnitude

        // Perform an out of bounds check by checking if the ball's center
        // is below the minimum point of the level. We require the ball be
        // below the minimum point by at least its diameter, as a buffer.
        return ballY < minY - (2 * ballRadius)
    }

    func teleportBall(to point: Point) {
        guard let ball = ball, let ballRigidBody = bridge.ballRigidBody else {
            return
        }

        let newHitbox = ball.hitBox.withCenter(point)
        self.ball?.update(hitBox: newHitbox)

        let newPosition = Vector2D(x: point.x, y: point.y)
        bridge.world.teleportRigidBody(
            ballRigidBody,
            to: mapper.localToExternal(vector: newPosition)
        )
    }

    func startExplosion(_ explosion: Explosion) {
        self.activeExplosions[explosion.id] = explosion

        bridge.addExplosion(explosion, onUpdate: { body in

            if body.elapsedTime > explosion.duration {
                // remove the explosion after its duration is up
                self.activeExplosions.removeValue(forKey: explosion.id)
                self.bridge.removeExplosion(explosion)
            } else {
                // otherwise update the explosion struct
                let radius = body.hitBox.width / 2
                self.activeExplosions[explosion.id]?.radius = radius
            }
        })
    }

    func removePeg(_ peg: Peg) {
        pegs[peg.id]?.remove()
        bridge.removePeg(peg)
    }

    // MARK: Helper Functions

    private func handleBallOutOfBounds() {
        // remove the current ball
        ball = nil
        bridge.removeBall()

        // add extra ball if ball was shot into bucket
        if obtainedBucketBonus {
            obtainedBucketBonus = false
            ballsRemaining += 1
        }

        // remove all pegs that were hit and not yet removed
        for peg in pegs.values {
            if !peg.hasBeenHit || peg.removed {
                continue
            }

            removePeg(peg)
        }

        // reset the cannon to allow players to fire another ball
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            self.cannon.reload()
        }
    }

    private func initializeBall(position: Point, velocity: Vector2D, radius: Float) {
        let ball = Ball(center: position, radius: Double(radius))
        self.ball = ball

        bridge.addBall(
            ball,
            initialVelocity: velocity,
            onUpdate: { body in
                print(body.velocity)
                self.ball?.update(hitBox: body.hitBox)
            })
    }

    private func initializePegs(levelBlueprint: LevelBlueprint) {
        for pegBlueprint in levelBlueprint.pegBlueprints {
            let peg = Peg(blueprint: pegBlueprint)
            pegs[peg.id] = peg

            bridge.addPeg(peg, onCollide: pegCollisionCallback(id: peg.id))
        }
    }

    private func initializeBucket() {
        bridge.addBucket(
            bucket,
            onUpdate: { body in
                self.bucket.updatePosition(body.hitBox.center)
            },
            onCollideWithInside: { collision in
                guard let body = self.bridge.ballRigidBody, collision.involvesBody(body) else {
                    return
                }

                self.obtainedBucketBonus = true
            }
        )
    }

    private func checkIfBallStuckAndResolve() {
        if lastNewPegCollisionTime > elapsedTime - 10 {
            return
        }

        // no new peg has been hit for the past 10 seconds, so we consider
        // the ball as stuck. to remedy, we remove a randomly chosen peg
        // that has already been hit, hopefully giving a route for the ball
        // to be unstuck
        let randomHitPeg = pegs
            .values
            .filter { $0.hasBeenHit }
            .randomElement()

        // if randomHitPeg is nil, then there are no pegs that have been
        // hit, so there is no peg to remove (the scenario where the ball
        // is stuck yet no pegs have been hit is likely impossible)
        guard let randomHitPeg = randomHitPeg else {
            return
        }

        lastNewPegCollisionTime = elapsedTime
        removePeg(randomHitPeg)
    }

    private func pegCollisionCallback(id: Peg.ID) -> (Collision) -> Void {
        { collision in
            guard let peg = self.pegs[id] else {
                return
            }

            /// A collision is only a valid collision if one of the bodies is either a ball or an explosion.
            /// We don't consider buckets and other pegs.
            let (isBallCollision, isExplosionCollision) = self.bridge.isBallOrExplosionCollision(collision)
            if !(isBallCollision || isExplosionCollision) {
                return
            }

            let hasBeenHit = peg.hasBeenHit
            // we need to access the peg directly from the dictionary, otherwise
            // we will only mutate the copy
            self.pegs[id]?.hit()

            // we need to specially consider the case where the peg has been
            // hit for the first time
            if !hasBeenHit {
                self.lastNewPegCollisionTime = self.elapsedTime

                // activate powerup if powerup peg was hit for the first time
                if PegType.isPowerup(peg.type) {
                    self.powerupManager.activatePowerup(
                        self.selectedPowerup,
                        hitPeg: peg
                    )
                }
            }

            if isExplosionCollision {
                self.removePeg(peg)
            }
        }
    }
}
