//
//  PeggleGameEngine.swift
//  Peggle

import Foundation
import Physics

let DefaultBallStartingSpeed = 400.0
let SpatialHashCellSize = 8.0
let DefaultNumStartingBalls = 10

class PeggleGameEngine: PeggleState {
    let width: Double
    let height: Double
    let viewportHeight: Double

    // `minY` is relative to the coordinate system used by the physics engine.
    // Balls that fall below `minY` are considered "out of bounds"
    private let minY: Double

    private let mapper: CoordinateMapper
    private var onUpdateCallback: ((PeggleState) -> Void)?

    private(set) var cameraOffsetY: Double = 0 {
        willSet { onUpdateCallback?(self) }
    }

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

    private(set) var ballsRemaining = DefaultNumStartingBalls {
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
    /// An `onUpdate` method can also be passed in, which will be called whenever any of
    /// the game objects receive updates.
    init(
        levelBlueprint: LevelBlueprint,
        maxX: Double,
        maxY: Double,
        viewportHeight: Double,
        powerupManager: PowerupManager,
        selectedPowerup: Powerup,
        coordinateMapper: CoordinateMapper = IdentityCoordinateMapper(),
        onUpdate: ((PeggleState) -> Void)? = nil,
        winConditions: WinConditions = [],
        loseConditions: LoseConditions = []
    ) {
        self.width = levelBlueprint.width
        self.height = levelBlueprint.gameplayHeight
        self.viewportHeight = levelBlueprint.minHeight

        self.mapper = coordinateMapper
        self.onUpdateCallback = onUpdate

        self.winConditions = winConditions
        self.loseConditions = loseConditions
        self.powerupManager = powerupManager
        self.selectedPowerup = selectedPowerup

        let world = World(
            broadPhaseCollisionDetector: SpatialHash(cellSize: SpatialHashCellSize),
            collisionResolver: ImpulseCollisionResolver(),
            minX: mapper.localToExternal(x: maxX) - mapper.localToExternal(x: width).magnitude,
            maxX: mapper.localToExternal(x: maxX),
            maxY: mapper.localToExternal(y: maxY)
        )

        self.minY = mapper.localToExternal(y: maxY) - mapper.localToExternal(y: height).magnitude

        self.bridge = PhysicsEngineBridge(world: world, coordinateMapper: mapper)

        self.cannon = Cannon(forLevelWidth: levelBlueprint.width)
        self.bucket = Bucket(forLevelWidth: levelBlueprint.width, forLevelHeight: levelBlueprint.gameplayHeight)

        initializeBucket()
        initializePegs(levelBlueprint: levelBlueprint)
        onUpdate?(self)
    }

    /// Fires the cannon, and adds a ball that has been "fired" to the default location for the balls
    /// (top-center of the game).
    /// The ball will be fired downwards with the given angle and speed.
    /// The angle must be between 0 and 180 degrees, with 0 corresponding to firing the ball parallel
    /// to the x-axis towards the right, and 180 corresponding to firing the ball parallel to the x-axis
    /// towards the left. If the angle is not between 0 and 180, the ball is not fired.
    /// - Returns: `true` if the ball was fired, and `false` otherwise.
    func fireBallWith(angle: Degrees, speed: Double = DefaultBallStartingSpeed) -> Bool {
        guard angle >= 0 && angle <= 180,
              status == .ongoing && ballsRemaining > 0 else {
            return false
        }

        cannon.fire()
        ballsRemaining -= 1
        AudioPlayer.default.playSound(.explosion)

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
                self.activeExplosions[explosion.id]?.radius = body.hitBox.width / 2
            }
        })
    }

    /// Removes the given peg from the physics simulation and sets it to `removed`.
    /// Returns true if the peg was successfully removed, and false otherwise.
    func removePeg(_ peg: Peg, force: Bool = false) -> Bool {
        let removed = pegs[peg.id]?.remove(force: force)
        if let removed = removed, removed {
            bridge.removePeg(peg)
        }
        return removed ?? false
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

        // remove all pegs that were hit and not yet removed.
        // if they were not removed (ie. a non interactive peg),
        // then we reset their hit status
        for peg in pegs.values {
            if !peg.hasBeenHit || peg.removed {
                continue
            }

            let removed = removePeg(peg)
            if !removed {
                pegs[peg.id]?.reset()
            }
        }

        // reset the cannon to allow players to fire another ball
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            self.cannon.reload()
        }
        // reset the camera
        cameraOffsetY = 0

        // check whether the game has been won or lost
        let newStatus = PeggleGameStatus.getStatusFor(
            state: self,
            winConditions: winConditions,
            loseConditions: loseConditions
        )

        if status != newStatus {
            status = newStatus
        }
    }

    private func initializeBall(position: Point, velocity: Vector2D, radius: Float) {
        let ball = Ball(center: position, radius: Double(radius))
        self.ball = ball

        bridge.addBall(
            ball,
            initialVelocity: velocity,
            onUpdate: { body in
                self.ball?.update(hitBox: body.hitBox)

                if let ball = self.ball {
                    self.adjustCameraOffset(ballY: ball.center.y)
                }
            },
            onCollide: { _ in AudioPlayer.default.playSound(.collision) }
        )
    }

    private func initializePegs(levelBlueprint: LevelBlueprint) {
        for blueprint in levelBlueprint.pegBlueprints.values {
            let peg = Peg(color: blueprint.color,
                          hitBox: blueprint.initialHitBox,
                          rotation: blueprint.rotation,
                          scale: blueprint.scale,
                          interactive: blueprint.interactive)
            pegs[peg.id] = peg

            bridge.addPeg(peg, onCollide: pegCollisionCallback(id: peg.id))
        }
    }

    private func initializeBucket() {
        bridge.addBucket(
            bucket,
            onUpdate: { self.bucket.updatePosition($0.hitBox.center) },
            onCollideWithInside: { collision in
                guard let body = self.bridge.ballRigidBody, collision.involvesBody(body) else {
                    return
                }

                self.obtainedBucketBonus = true
            }
        )
    }

    /// Adjusts the camera offset based on the current y position of the ball. The ball should always be between
    /// the 30% to 50% height of the level, unless the ball is at the top or bottom of the level.
    private func adjustCameraOffset(ballY: Double) {
        let over = ballY - (self.cameraOffsetY + self.viewportHeight * 0.5)
        if over > 0 {
            // total height - viewport height is the camera offset such that the bottom of the level
            // is positioned at the bottom of the screen
            self.cameraOffsetY = min(self.height - self.viewportHeight, self.cameraOffsetY + over)
        }

        let under = (self.cameraOffsetY + self.viewportHeight * 0.3) - ballY
        if under > 0 {
            self.cameraOffsetY = max(0, self.cameraOffsetY - under)
        }
    }

    private func checkIfBallStuckAndResolve() {
        if lastNewPegCollisionTime > elapsedTime - 15 {
            return
        }

        // no new peg has been hit for the past 15 seconds, so we consider
        // the ball as stuck. to remedy, we remove a randomly chosen peg
        // that has already been hit, hopefully giving a route for the ball
        // to be unstuck
        let randomHitPeg = pegs.values
            .filter { $0.hasBeenHit }
            .randomElement()

        // if randomHitPeg is nil, then there are no pegs that have been
        // hit, so there is no peg to remove (the scenario where the ball
        // is stuck yet no pegs have been hit is likely impossible)
        guard let randomHitPeg = randomHitPeg else {
            return
        }

        lastNewPegCollisionTime = elapsedTime
        _ = removePeg(randomHitPeg, force: true)
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
            self.pegs[id]?.hit()

            // we need to specially consider the case where the peg has been
            // hit for the first time
            if !hasBeenHit {
                self.lastNewPegCollisionTime = self.elapsedTime

                // activate powerup if powerup peg was hit for the first time
                if peg.isPowerup() {
                    self.powerupManager.activatePowerup(self.selectedPowerup, hitPeg: peg)
                }
            }

            if isExplosionCollision {
                _ = self.removePeg(peg, force: true)
            }
        }
    }
}
