//
//  LevelSelectionViewModel.swift
//  Peggle

import SwiftUI

class LevelSelectionViewModel: ObservableObject {

    private let repo: LevelBlueprintRepo

    @Published var levelNames: Set<String> = []

    init(repo: LevelBlueprintRepo) {
        self.repo = repo
    }

    func loadLevelNames() throws {
        let names = try repo.getAllBlueprintNames()
        levelNames = names
    }

    func loadLevelBlueprint(name: String) throws -> LevelBlueprint? {
        try repo.loadBlueprint(name: name)
    }
}
