//
//  Sound.swift
//  Peggle

import UIKit
import AVFoundation

enum Sound: CaseIterable {
    case bgmUpbeat
    case bgmRelaxed
    case explosion
    case collision
    case failure
    case victory

    var asset: NSDataAsset? {
        switch self {
        case .bgmUpbeat:
            return NSDataAsset(name: "BgmUpbeat")
        case .bgmRelaxed:
            return NSDataAsset(name: "BgmRelaxed")
        case .explosion:
            return NSDataAsset(name: "SoundExplosion")
        case .collision:
            return NSDataAsset(name: "SoundCollision")
        case .failure:
            return NSDataAsset(name: "SoundFailure")
        case .victory:
            return NSDataAsset(name: "SoundVictory")
        }
    }

    var ext: String {
        AVFileType.mp3.rawValue
    }

    var isLooped: Bool {
        switch self {
        case .bgmUpbeat:
            return true
        case .bgmRelaxed:
            return true
        case .explosion:
            return false
        case .collision:
            return false
        case .failure:
            return false
        case .victory:
            return false
        }
    }

    var type: SoundType {
        switch self {
        case .bgmUpbeat:
            return .background
        case .bgmRelaxed:
            return .background
        case .explosion:
            return .soundEffect
        case .collision:
            return .soundEffect
        case .failure:
            return .soundEffect
        case .victory:
            return .soundEffect
        }
    }
}

enum SoundType {
    case background
    case soundEffect
}
