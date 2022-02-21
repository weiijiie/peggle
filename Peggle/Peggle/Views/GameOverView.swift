//
//  GameOverView.swift
//  Peggle

import SwiftUI

struct GameOverView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>

    let status: PeggleGameStatus
    let levelName: String

    let playAgainCallback: () -> Void

    var resultMessage: some View {
        Group {
            if status == .won {
                Text("Victory!")
                    .foregroundColor(.green)
            } else if status == .lost {
                Text("Level Failed")
                    .foregroundColor(.red)
            }
        }
        .font(.title2)
    }

    var buttons: some View {
        HStack(spacing: 24) {
            Button("Play Again") {
                playAgainCallback()
            }
            .buttonStyle(.borderedProminent)

            Button("Back") {
                navigator.navigateBack()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            Text(levelName).font(.title)
            Spacer()
            resultMessage
            Text("Score: 123")
            Spacer()
            buttons
        }
        .padding()
        .frame(minWidth: 280, maxHeight: 480)
    }
}

struct GameResultView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.darkGray)
            GameOverView(status: .won, levelName: "myLevel", playAgainCallback: {})
        }
        ZStack {
            Color(.darkGray)
            GameOverView(status: .lost, levelName: "myLevel", playAgainCallback: {})
        }
    }
}
