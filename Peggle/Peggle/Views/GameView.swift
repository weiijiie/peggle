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
            Button {
                navigator.navigateTo(route: .levelDesigner)
            } label: {
                Label("Back", systemImage: "arrow.backward")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var game: some View {
        ZStack {
            if let levelBlueprint = appState.activeLevelBlueprint {
                GameBackground(width: levelBlueprint.width, height: levelBlueprint.height)
                    .onAppear { viewModel.initializeGame(levelBlueprint: levelBlueprint) }
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

                GameResultView(
                    status: viewModel.gameStatus,
                    levelName: appState.activeLevelName,
                    playAgainCallback: { viewModel.initializeGame(levelBlueprint: levelBlueprint) }
                )

            } else {
                Text("No level blueprint loaded!")
            }

        }
    }

    var body: some View {
        VStack {
            topBar
            game
        }
        .ignoresSafeArea(.keyboard)

    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(appState: AppState())
    }
}
