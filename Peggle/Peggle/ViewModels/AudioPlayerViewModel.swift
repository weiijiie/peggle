//
//  AudioPlayerViewModel.swift
//  Peggle

import SwiftUI
import Combine

class AudioPlayerViewModel: ObservableObject {
    @Published var audioPlayer = AudioPlayer.default

    @Published private(set) var muted = false

    private var mutedCancellable: AnyCancellable?

    init() {
        muted = audioPlayer.muted
        mutedCancellable = audioPlayer.$muted.sink { val in
            self.muted = val
        }
    }

    func playSound(_ sound: Sound) {
        audioPlayer.playSound(sound)
    }

    func toggleMuted() {
        audioPlayer.muted.toggle()
    }
}
