//
//  AppViewModel.swift
//  Peggle

import SwiftUI

class AppState: ObservableObject {
    @Published var activeLevelBlueprint: LevelBlueprint?

    func setActiveLevelBlueprint(_ blueprint: LevelBlueprint?) {
        activeLevelBlueprint = blueprint
    }
}
