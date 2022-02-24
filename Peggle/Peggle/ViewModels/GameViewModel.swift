//
//  GameViewModel.swift
//  Peggle

import SwiftUI
import Physics

typealias GameObjects = (
    ball: Ball?,
    pegs: [Peg],
    cannon: Cannon,
    bucket: Bucket,
    explosions: [Explosion]
)

class GameViewModel: ObservableObject {

    // Experimentally, this scaling from the view's coordinates to the game
    // engine's coordinates leads to a more enjoyable simulation.
    static let GameEngineScaleFactor = 1.0 / 20

    var gameEngine: PeggleGameEngine?

    private var displayLink: CADisplayLink?

    var gameObjects: GameObjects? {
        guard let gameEngine = gameEngine else {
            return nil
        }

        return (
            ball: gameEngine.ball,
            pegs: gameEngine.pegs,
            cannon: gameEngine.cannon,
            bucket: gameEngine.bucket,
            explosions: Array(gameEngine.activeExplosions.values)
        )
    }

    var ballsRemaining: Int {
        gameEngine?.ballsRemaining ?? 0
    }

    var gameStatus: PeggleGameStatus {
        gameEngine?.status ?? .ongoing
    }

    // Powerup selection
    let availablePowerups = AllPowerups

    // Set the default to be the first powerup in `AllPowerups`
    // There should always at least be one powerup in that array
    @Published var selectedPowerup: Powerup = AllPowerups.first!
    @Published var showSelectPowerupScreen = true

    /// Whether the game loop is running or not. Assigning to this value will cause the
    /// game loop to start and stop appropriately. This allows for binded variables to
    /// affect game's paused state.
    @Published var paused = false {
        willSet {
            if newValue {
                stopGameLoop()
            } else {
                startGameLoop()
            }
        }
    }

    @Published var showGameOverScreen = false

    /// Initializes the peggle game engine with the given level blueprint, then starts the game
    /// loop to start the game. Does nothing if the provided level blueprint is `nil`
    func initializeGame(blueprint levelBlueprint: LevelBlueprint?) {
        guard let levelBlueprint = levelBlueprint else {
            return
        }

        // stop any prior running game
        stopGameLoop()

        let scaleFactor = GameViewModel.GameEngineScaleFactor
        let coordinateMapper = ProportionateCoordinateMapper(scale: scaleFactor).withFlippedYAxis()

        self.gameEngine = PeggleGameEngine(
            levelBlueprint: levelBlueprint,
            maxX: levelBlueprint.width,
            maxY: 0, // in iOS, the 0 coordinate is towards the top of the screen
            powerupManager: PowerupManager(),
            selectedPowerup: selectedPowerup,
            coordinateMapper: coordinateMapper,
            // Since the game engine is a class, SwiftUI does not know when it has
            // been mutated. Thus, we use a callback based system to call
            // objectWillChange.send(), which will tell SwiftUI to re-render
            // any views that depend on properties on the observed object.
            onUpdate: { state in
                self.showGameOverScreen = state.status.isGameOver()
                self.objectWillChange.send()
            },
            winConditions: [ClearAllOrangePegsWinCondition()],
            loseConditions: [RanOutOfBallsLoseCondition()]
        )

        startGameLoop()
    }

    func fireBallWith(cannonAngle: Degrees) -> Bool {
        let success = gameEngine?.fireBallWith(angle: cannonAngle)
        guard let success = success, success else {
            return false
        }

        return true
    }

    func stopGame() {
        gameEngine = nil
        selectedPowerup = AllPowerups.first!
        showSelectPowerupScreen = true
        paused = false
        showGameOverScreen = false
        stopGameLoop()
    }

    private func startGameLoop() {
        if displayLink != nil {
            return
        }

        let displaylink = CADisplayLink(target: self, selector: #selector(frame))
        displaylink.add(to: .current, forMode: RunLoop.Mode.default)

        self.displayLink = displaylink
    }

    private func stopGameLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc
    func frame(displayLink: CADisplayLink) {
        let frameDuration = displayLink.targetTimestamp - displayLink.timestamp
        gameEngine?.update(dt: Float(frameDuration))
    }
}
