//
//  MenuView.swift
//  Peggle

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @EnvironmentObject var audioPlayer: AudioPlayerViewModel

    @ObservedObject var appState: AppState

    var settings: some View {
        HStack {
            Spacer()
            Button {
                audioPlayer.toggleMuted()
            } label: {
                if audioPlayer.muted {
                    Label("Muted", systemImage: "speaker.slash.fill")
                        .font(.title)
                        .labelStyle(.iconOnly)
                } else {
                    Label("Sound On", systemImage: "speaker.wave.1")
                        .font(.title)
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GameBackgroundView(width: geometry.size.width, height: geometry.size.height)

                VStack(spacing: 24) {
                    settings
                    Spacer()
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
                    Spacer()
                }
                .padding()
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
