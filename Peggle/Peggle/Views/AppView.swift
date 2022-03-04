//
//  ContentView.swift
//  Peggle

import SwiftUI

/// Top level view for the Peggle application
struct AppView: View {
    let router = Router(initialRoute: PeggleRoute.menu)

    @StateObject var appState = AppState()
    @StateObject var audioPlayer = AudioPlayerViewModel()

    var body: some View {
        router.provider {
            router.route(for: .menu) {
                MenuView(appState: appState)
                    .onAppear {
                        audioPlayer.playSound(.bgmRelaxed)
                    }
            }
            router.route(for: .levelDesigner) {
                LevelDesignerView(appState: appState)
                    .onAppear {
                        audioPlayer.playSound(.bgmRelaxed)
                    }
            }
            router.route(for: .game) {
                GameView(appState: appState)
                    .onAppear {
                        audioPlayer.playSound(.bgmUpbeat)
                    }
            }
        }
        .environmentObject(audioPlayer)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
