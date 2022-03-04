//
//  GameView.swift
//  Peggle

import SwiftUI
import Physics

struct GameView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @EnvironmentObject var audioPlayer: AudioPlayerViewModel

    @ObservedObject var appState: AppState
    @StateObject var viewModel = GameViewModel()

    var ballsLeftIndicator: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("\(viewModel.ballsRemaining)".padding(toLength: 3, withPad: " ", startingAt: 0))
                .font(.title)
            Image("Ball")
                .resizable()
                .clipped()
                .scaledToFill()
                .frame(width: 32, height: 32)
            Text("left")
                .font(.title2)
        }
    }

    var winConditionPegsLeftIndicator: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("\(viewModel.winConditionPegsRemaining)".padding(toLength: 3, withPad: " ", startingAt: 0))
                .font(.title)
            Image("PegOrange")
                .resizable()
                .clipped()
                .scaledToFill()
                .frame(width: 36, height: 36)
            Text("left to clear")
                .font(.title2)
        }
    }

    var topBar: some View {
        VStack {
            HStack(spacing: 15) {
                Spacer()
                Button {
                    viewModel.paused = true
                } label: {
                    Image(systemName: "pause")
                        .font(.system(size: 36, weight: .heavy))
                }
            }
            Spacer()
            HStack {
                Spacer()
                ballsLeftIndicator
                Spacer()
                winConditionPegsLeftIndicator
                Spacer()
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.white)
    }

    func game(blueprint levelBlueprint: LevelBlueprint) -> some View {
        GeometryReader { geometry in
            ZStack {
                GameBackgroundView(width: geometry.size.width, height: geometry.size.height)

                if let objects = viewModel.gameObjects {
                    gameObjects(objects)
                        .offset(y: -viewModel.cameraOffsetY)
                        .scaleEffect(geometry.size.width / levelBlueprint.width, anchor: .topLeading)
                }
            }
            .onChange(of: viewModel.gameStatus) { value in
                if value == .won {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        audioPlayer.playSound(.victory)
                    }
                } else if value == .lost {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        audioPlayer.playSound(.failure)
                    }
                }
            }
        }
    }

    func gameObjects(_ gameObjects: GameObjects) -> some View {
        let (ball, pegs, cannon, bucket, explosions) = gameObjects
        return Group {
            if let ball = ball {
                BallView(ball: ball)
            }

            ForEach(pegs, id: \.id) { peg in
                PegView(peg: peg)
            }

            ForEach(explosions, id: \.id) { explosion in
                ExplosionView(explosion: explosion)
            }

            BucketView(bucket: bucket)

            CannonView(cannon: cannon) { cannon in
                _ = viewModel.fireBallWith(cannonAngle: cannon.currentAngle)
            }
            .onDisappear {
                viewModel.stopGame()
                appState.unsetActiveLevelBlueprint()
            }
        }
    }

    var body: some View {
        if let (levelBlueprint, levelName) = appState.activeLevelBlueprint {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    topBar.frame(height: 0.18 * geometry.size.height)
                    game(blueprint: levelBlueprint)
                        .zIndex(-1)
                }
                .popup(isPresented: $viewModel.showSelectPowerupScreen) {
                    PowerupSelectionView(
                        availablePowerups: viewModel.availablePowerups,
                        powerupSelectedCallback: { powerup in
                            viewModel.selectedPowerup = powerup
                            viewModel.showSelectPowerupScreen = false
                            viewModel.initializeGame(blueprint: levelBlueprint)
                        }
                    )
                } onDismiss: { viewModel.initializeGame(blueprint: levelBlueprint)
                }
                .popup(isPresented: $viewModel.paused) {
                    GameMenuView(show: $viewModel.paused, restartCallback: {
                        viewModel.initializeGame(blueprint: levelBlueprint)
                    })
                }
                .popup(isPresented: $viewModel.showGameOverScreen, tapOutsideToDismiss: false) {
                    GameOverView(
                        status: viewModel.gameStatus,
                        levelName: levelName,
                        playAgainCallback: { viewModel.initializeGame(blueprint: levelBlueprint) }
                    )
                }
            }
        } else {
            LevelSelectionView { blueprint, name in
                appState.setActiveLevelBlueprint(blueprint, name: name)
            } onCancel: {
                navigator.navigateBack()
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(appState: AppState())
    }
}
