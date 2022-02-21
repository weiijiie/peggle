//
//  GameView.swift
//  Peggle

import SwiftUI
import Physics

struct GameView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @ObservedObject var appState: AppState
    @StateObject var viewModel = GameViewModel()

    var topBar: some View {
        HStack(spacing: 15) {
            Spacer()
            Button {
                viewModel.paused = true
            } label: {
                Image(systemName: "pause")
                    .font(.system(size: 36, weight: .heavy))
            }
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    func game(blueprint levelBlueprint: LevelBlueprint) -> some View {
        ZStack {
            GameBackgroundView(width: levelBlueprint.width, height: levelBlueprint.height)
                .onAppear { viewModel.initializeGame(blueprint: levelBlueprint) }
                .onDisappear { viewModel.stopGame() }

            if let ball = viewModel.ball {
                BallView(ball: ball)
            }

            if let cannon = viewModel.cannon {
                CannonView(cannon: cannon) { cannon in
                    _ = viewModel.fireBallWith(cannonAngle: cannon.currentAngle)
                }
            }

            ForEach(viewModel.pegs, id: \.id) { peg in
                PegView(peg: peg)
            }
        }
    }

    var body: some View {
        ZStack {
            if let (levelBlueprint, levelName) = appState.activeLevelBlueprint {
                VStack {
                    topBar
                    game(blueprint: levelBlueprint)
                }
                .ignoresSafeArea(.keyboard)
                .popup(isPresented: $viewModel.paused) {
                    GameMenuView(show: $viewModel.paused, restartCallback: {
                        viewModel.initializeGame(blueprint: levelBlueprint)
                    })
                }
                .popup(isPresented: $viewModel.showGameOverScreen, tapOutsideToDismiss: false) {
                    GameOverView(
                        status: viewModel.gameStatus,
                        levelName: levelName,
                        playAgainCallback: {
                            viewModel.initializeGame(blueprint: levelBlueprint)
                        }
                    )
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
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(appState: AppState())
    }
}
