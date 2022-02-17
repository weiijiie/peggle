//
//  LevelBlueprintFileRepo.swift
//  Peggle

import Foundation

/// Implementation of `LevelBlueprintRepo` that saves the blueprints as JSON encoded files.
class LevelBlueprintFileRepo: LevelBlueprintRepo {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let prefix = "lvl-blueprint"

    func saveBlueprint(name: String, blueprint: LevelBlueprint) throws {
        let data = try encoder.encode(blueprint)
        let url = getFileURL(from: getFileName(blueprintName: name), with: "json")

        try data.write(to: url)
    }

    func loadBlueprint(name: String) throws -> LevelBlueprint {
        let url = getFileURL(from: getFileName(blueprintName: name), with: "json")

        do {
            let data = try Data(contentsOf: url)
            let result = try decoder.decode(LevelBlueprint.self, from: data)
            return result

        } catch let error as NSError where error.code == NSFileReadNoSuchFileError {
            throw LevelBlueprintRepoError.blueprintNotFound(name: name)

        } catch {
            throw error
        }
    }

    private func getFileName(blueprintName: String) -> String {
        "\(prefix)-\(blueprintName)"
    }

    private func getFileURL(from name: String, with ext: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(name).appendingPathExtension(ext)
    }
}
