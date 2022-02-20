//
//  GameViewModel.swift
//  Peggle

import SwiftUI
import Physics

class GameViewModel: ObservableObject {

    // Experimentally, this scaling from the view's coordinates to the game
    // engine's coordinates leads to a more enjoyable simulation.
    static let GameEngineScaleFactor = 1.0 / 25

    var gameEngine: PeggleGameEngine?

    private var displayLink: CADisplayLink?

    var cannon: Cannon? {
        gameEngine?.cannon
    }

    var ball: Ball? {
        gameEngine?.ball
    }

    var pegs: [Peg] {
        gameEngine?.pegs ?? []
    }

    var gameStatus: PeggleGameStatus {
        gameEngine?.status ?? .ongoing
    }

    func initializeGame(levelBlueprint: LevelBlueprint) {
        // stop any prior running game
        stopGame()

        let scaleFactor = GameViewModel.GameEngineScaleFactor
        let coordinateMapper = ProportionateCoordinateMapper(scale: scaleFactor).withFlippedYAxis()

        let gameEngine = PeggleGameEngine(
            levelBlueprint: levelBlueprint,
            maxX: levelBlueprint.width,
            maxY: 0, // in iOS, the 0 coordinate is towards the top of the screen
            coordinateMapper: coordinateMapper,
            // Since the game engine is a class, SwiftUI does not know when it has
            // been mutated. Thus, we use a callback based system to call
            // objectWillChange.send(), which will tell SwiftUI to re-render
            // any views that depend on properties on the observed object.
            onUpdate: { self.objectWillChange.send() },
            winConditions: [ClearAllOrangePegsWinCondition()],
            loseConditions: [RanOutOfBallsLoseCondition()]
        )

        self.gameEngine = gameEngine
        startGameLoop()
    }

    func fireBallWith(cannonAngle: Degrees) -> Bool {
        let success = gameEngine?.fireBallWith(angle: cannonAngle)
        guard let success = success, success else {
            return false
        }

        return true
    }

    private func startGameLoop() {
        let displaylink = CADisplayLink(target: self, selector: #selector(frame))
        displaylink.add(to: .current, forMode: RunLoop.Mode.default)

        self.displayLink = displaylink
    }

    func stopGame() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc
    func frame(displayLink: CADisplayLink) {
        let frameDuration = displayLink.targetTimestamp - displayLink.timestamp
        gameEngine?.update(dt: Float(frameDuration))
    }
}
