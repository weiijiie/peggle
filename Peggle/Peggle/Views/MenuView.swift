//
//  MenuView.swift
//  Peggle

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @ObservedObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GameBackgroundView(width: geometry.size.width, height: geometry.size.height)
                VStack(spacing: 24) {
                    Text("Peggle")
                        .font(.largeTitle)

                    Spacer()
                    Button("PLAY") {
                        navigator.navigateTo(route: .game)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("DESIGN YOUR OWN LEVEL") {
                        navigator.navigateTo(route: .levelDesigner)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(height: 0.5 * geometry.size.height, alignment: .center)
            }
            .onAppear {
                appState.unsetActiveLevelBlueprint()
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(appState: AppState())
    }
}
