//
//  AppViewModel.swift
//  Peggle

import SwiftUI

class AppState: ObservableObject {
    @Published var activeLevelBlueprint: LevelBlueprint?
    @Published var activeLevelName: String = ""

    func setActiveLevelBlueprint(_ blueprint: LevelBlueprint?, name: String) {
        activeLevelBlueprint = blueprint
        activeLevelName = name
    }
}
