//
//  ContentView.swift
//  Peggle

import SwiftUI

/// Top level view for the Peggle application
struct AppView: View {
    let router = Router(initialRoute: PeggleRoute.levelDesigner)

    @StateObject var appState = AppState()

    var body: some View {
        router.provider {
            router.route(for: .levelDesigner) {
                LevelDesignerView(appState: appState)
            }
            router.route(for: .game) {
                GameView(appState: appState)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
