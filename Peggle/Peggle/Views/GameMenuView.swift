//
//  GameMenuView.swift
//  Peggle

import SwiftUI

struct GameMenuView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @EnvironmentObject var audioPlayer: AudioPlayerViewModel

    @Binding var show: Bool

    let restartCallback: () -> Void

    var soundControl: some View {
        Button {
            audioPlayer.toggleMuted()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(audioPlayer.muted ? .systemGray2 : .white))
                .overlay {
                    if audioPlayer.muted {
                        Label("Muted", systemImage: "speaker.slash.fill")
                            .font(.title)
                            .labelStyle(.iconOnly)
                            .padding(4)

                    } else {
                        Label("Sound On", systemImage: "speaker.wave.1")
                            .font(.title)
                            .labelStyle(.iconOnly)
                            .padding(4)
                    }
                }
                .frame(width: 42, height: 42)
        }
    }

    var settings: some View {
        HStack {
            Spacer()
            soundControl
            Spacer()
        }
        .frame(height: 36)
        .padding(.horizontal)
    }

    var body: some View {
        if show {
            VStack(spacing: 36) {
                settings
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
            .frame(maxWidth: 280, minHeight: 320)
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
