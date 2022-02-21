//
//  AppViewModel.swift
//  Peggle

import SwiftUI

class AppState: ObservableObject {
    @Published private(set) var activeLevelBlueprint: (blueprint: LevelBlueprint, name: String)?

    func setActiveLevelBlueprint(_ blueprint: LevelBlueprint, name: String) {
        activeLevelBlueprint = (blueprint, name)
    }

    func unsetActiveLevelBlueprint() {
        activeLevelBlueprint = nil
    }
}
