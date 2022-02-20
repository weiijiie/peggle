//
//  GameResultView.swift
//  Peggle

import SwiftUI

struct GameResultView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @State var show = false

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
        .font(.headline)
    }

    var buttons: some View {
        HStack(spacing: 24) {
            Button("Play Again") {
                withAnimation(.spring()) {
                    show = false
                }
                playAgainCallback()
            }
            .buttonStyle(.borderedProminent)
            Button("Back to Menu") {
                navigator.navigateTo(route: .levelDesigner)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var bg: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(.gray, lineWidth: 2)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            )
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            if show {
                VStack(alignment: .center, spacing: 12) {
                    Text(levelName).font(.title)
                    Spacer()
                    resultMessage
                    Text("Score: 123")
                    Spacer()
                    buttons
                }
                .padding()
                .background(bg)
                .frame(height: 0.6 * height)
                .position(x: width / 2, y: height / 2)
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onChange(of: status) { newValue in
            withAnimation(.spring().delay(1.5)) {
                show = newValue == .won || newValue == .lost
            }
        }
    }
}

struct GameResultView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.darkGray)
            GameResultView(status: .won, levelName: "myLevel", playAgainCallback: {})
        }
        ZStack {
            Color(.darkGray)
            GameResultView(status: .lost, levelName: "myLevel", playAgainCallback: {})
        }
    }
}
