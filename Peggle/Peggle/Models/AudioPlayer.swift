//
//  AudioPlayer.swift
//  Peggle

import AVFoundation
import Combine
import SwiftUI

class AudioPlayer {
    /// Singleton default audio player instance.
    static let `default` = AudioPlayer()

    /// Plays background music. Only one track can be playing at a time, new tracks will override
    /// prior tracks.
    var bgmPlayer: AVAudioPlayer?

    /// Plays sound effects. Multiple different sound effects can be playing at a time.
    var soundEffectPlayers: [Sound: AVAudioPlayer] = [:]

    @Published var muted = false {
        didSet {
            if muted {
                bgmPlayer?.volume = 0
            } else {
                bgmPlayer?.volume = 1
            }
        }
    }

    /// We use publishers to debounce sounds of the same type so that they don't overwhelm the player
    /// if many are triggered in a row.
    private let soundSubjects: [Sound: PassthroughSubject<Sound, Never>]
    private var cancellables = [AnyCancellable]()

    init() {
        soundSubjects = Dictionary(uniqueKeysWithValues: Sound.allCases.map { sound in
            (sound, PassthroughSubject<Sound, Never>())
        })

        for subject in soundSubjects.values {
            subject
                .debounce(for: .milliseconds(30), scheduler: RunLoop.main)
                .sink(receiveValue: playQueuedSound)
                .store(in: &cancellables)
        }
    }

    func playSound(_ sound: Sound) {
        soundSubjects[sound]?.send(sound)
    }

    private func playQueuedSound(_ sound: Sound) {
        guard let asset = sound.asset else {
            print("Asset not found for sound: \(sound)")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            switch sound.type {

            case .background:
                bgmPlayer = try AVAudioPlayer(data: asset.data, fileTypeHint: sound.ext)

                if sound.isLooped {
                    bgmPlayer?.numberOfLoops = -1
                }

                if muted {
                    bgmPlayer?.volume = 0
                }

                bgmPlayer?.play()

            case .soundEffect:
                soundEffectPlayers[sound] = try AVAudioPlayer(data: asset.data, fileTypeHint: sound.ext)

                if sound.isLooped {
                    soundEffectPlayers[sound]?.numberOfLoops = -1
                }

                if muted {
                    soundEffectPlayers[sound]?.volume = 0
                }

                soundEffectPlayers[sound]?.play()
            }

        } catch let error as NSError {
            print("audio error: \(error.localizedDescription)")
        }
    }
}
