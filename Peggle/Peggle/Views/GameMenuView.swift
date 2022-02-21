//
//  GameMenuView.swift
//  Peggle

import SwiftUI

struct GameMenuView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>

    @Binding var show: Bool

    let restartCallback: () -> Void

    var body: some View {
        if show {
            VStack(spacing: 36) {
                Button("Restart", role: .destructive) {
                    show = false
                    restartCallback()
                }

                Button("Resume") {
                    show = false
                }
                .buttonStyle(.borderedProminent)

                Button("Exit") {
                    show = false
                    navigator.navigateBack()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(minWidth: 280, minHeight: 320)
            .padding()
        }
    }
}

struct GameMenuView_Previews: PreviewProvider {
    @State static var show = true

    static var previews: some View {
        GameMenuView(show: $show, restartCallback: {})
    }
}
