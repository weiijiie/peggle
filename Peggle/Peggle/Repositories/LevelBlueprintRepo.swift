//
//  LevelBlueprintRepo.swift
//  Peggle

enum LevelBlueprintRepoError: Error {
    case blueprintNotFound(name: String)
}

protocol LevelBlueprintRepo {
    func saveBlueprint(name: String, blueprint: LevelBlueprint) throws
    func loadBlueprint(name: String) throws -> LevelBlueprint
}
