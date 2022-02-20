//
//  PeggleGameEngine.swift
//  Peggle

import Foundation
import Physics

class PeggleGameEngine: PeggleState {

    static let DefaultBallSpeed = 450.0
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

    private let world: World<SpatialHash<RigidBody>, ImpulseCollisionResolver>

    private let mapper: CoordinateMapper

    private var onUpdateCallback: (() -> Void)?

    private(set) var cannon: Cannon {
        willSet {
            onUpdateCallback?()
        }
    }

    private(set) var ball: Ball? {
        willSet {
            onUpdateCallback?()
        }
    }

    private(set) var pegs: [Peg] = [] {
        willSet {
            onUpdateCallback?()
        }
    }

    private(set) var ballsRemaining = PeggleGameEngine.DefaultNumStartingBalls

    private(set) var status = PeggleGameStatus.ongoing {
        willSet {
            onUpdateCallback?()
        }
    }

    private(set) var winConditions: WinConditions
    private(set) var loseConditions: LoseConditions

    private var pegIdToRigidBody: [Peg.ID: RigidBody] = [:]

    private var elapsedTime: Float = 0
    private var lastNewPegCollisionTime: Float = 0

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
        coordinateMapper: CoordinateMapper = IdentityCoordinateMapper(),
        onUpdate: (() -> Void)? = nil,
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

        self.world = World(
            broadPhaseCollisionDetector: SpatialHash(cellSize: PeggleGameEngine.SpatialHashCellSize),
            collisionResolver: ImpulseCollisionResolver(),
            minX: self.minX,
            maxX: self.maxX,
            maxY: self.maxY
        )

        self.winConditions = winConditions
        self.loseConditions = loseConditions

        self.cannon = Cannon(forLevelWidth: levelBlueprint.width)
        initializePegs(levelBlueprint: levelBlueprint)
        onUpdate?()
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
    func fireBallWith(angle: Degrees, speed: Double = PeggleGameEngine.DefaultBallSpeed) -> Bool {
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
        world.update(dt: dt)

        // the cannon's rotation is not handled by the physics engine, so
        // we handle it separately
        cannon.stepForwardBy(dt: dt)

        checkIfBallStuckAndResolve()

        if winConditions.hasWon(state: self) {
            status = .won
        } else if loseConditions.hasLost(state: self) {
            status = .lost
        }
    }

    func isBallOutOfBounds() -> Bool {
        guard let ball = ball else {
            return false
        }

        let ballY = mapper.localToExternal(y: ball.center.y)
        let ballRadius = mapper.localToExternal(y: ball.radius)

        // Perform an out of bounds check by checking if the ball's center
        // is below the minimum point of the level. We require the ball be
        // below the minimum point by at least its diameter, as a buffer.
        return ballY < minY - (2 * ballRadius)
    }

    // MARK: Helper Functions

    private func handleBallOutOfBounds(ballRigidBody: RigidBody) {
        // remove the current ball
        world.removeRigidBody(ballRigidBody)
        ball = nil

        // remove all pegs that were hit
        for peg in pegs {
            if !peg.hasBeenHit || peg.removed {
                continue
            }

            removePeg(peg)
        }

        // reset the cannon to allow players to fire another ball
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.cannon.reload()
        }
    }

    private func initializeBall(position: Point, velocity: Vector2D, radius: Float) {
        let ball = Ball(center: position, radius: Double(radius))

        self.ball = ball

        let rigidBody = rigidBodyForBall(ball, initialVelocity: velocity)
        world.addRigidBody(
            rigidBody,
            onUpdate: { body in
                let hitBox = self.mapper.externalToLocal(geometry: body.hitBox)
                self.ball?.update(hitBox: hitBox)

                // After each update of the ball's rigid body, check if out of bounds
                if self.isBallOutOfBounds() {
                    self.handleBallOutOfBounds(ballRigidBody: rigidBody)
                }
            }
        )
    }

    private func initializePegs(levelBlueprint: LevelBlueprint) {
        for (i, pegBlueprint) in levelBlueprint.pegBlueprints.enumerated() {
            // we let the peg's ID be their index in the pegs array
            let peg = Peg(id: i, blueprint: pegBlueprint)
            pegs.append(peg)

            let rigidBody = rigidBodyForPeg(peg)
            world.addRigidBody(
                rigidBody,
                onCollide: { _ in
                    let hasBeenHit = self.pegs[peg.id].hasBeenHit

                    if !hasBeenHit {
                        self.pegs[peg.id].hit()
                        self.lastNewPegCollisionTime = self.elapsedTime
                    }
                }
            )

            pegIdToRigidBody[peg.id] = rigidBody
        }
    }

    private func rigidBodyForBall(_ ball: Ball, initialVelocity: Vector2D) -> RigidBody {
        let hitBox = mapper.localToExternal(geometry: ball.hitBox)
        let initialPosition = Vector2D(x: ball.center.x, y: ball.center.y)

        return RigidBody(
            motion: .dynamic(
                position: mapper.localToExternal(vector: initialPosition),
                velocity: mapper.localToExternal(vector: initialVelocity),
                mass: ball.mass
            ),
            hitBoxAt: { center in hitBox.withCenter(center) },
            material: ball.material
        )
    }

    private func rigidBodyForPeg(_ peg: Peg) -> RigidBody {
        let hitBox = mapper.localToExternal(geometry: peg.hitBox)
        let initialPosition = Vector2D(x: peg.center.x, y: peg.center.y)

        return RigidBody(
            motion: .static(position: mapper.localToExternal(vector: initialPosition)),
            hitBoxAt: { center in hitBox.withCenter(center) }
        )
    }

    private func checkIfBallStuckAndResolve() {
        // no new peg has been hit for the past 10 seconds
        if lastNewPegCollisionTime < elapsedTime - 10 {
            let randomHitPeg = pegs
                .filter { $0.hasBeenHit }
                .randomElement()

            // if randomHitPeg is nil, then there are no pegs anyway so
            // there is no peg to remove
            guard let randomHitPeg = randomHitPeg else {
                return
            }

            // refresh the last collision time
            lastNewPegCollisionTime = elapsedTime
            removePeg(randomHitPeg)
        }
    }

    private func removePeg(_ peg: Peg) {
        pegs[peg.id].remove()

        guard let rigidBody = pegIdToRigidBody[peg.id] else {
            return
        }

        world.removeRigidBody(rigidBody)
    }
}
