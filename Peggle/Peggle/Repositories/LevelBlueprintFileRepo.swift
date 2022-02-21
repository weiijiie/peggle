//
//  LevelBlueprintFileRepo.swift
//  Peggle

import Foundation

/// Implementation of `LevelBlueprintRepo` that saves the blueprints as JSON encoded files.
class LevelBlueprintFileRepo: LevelBlueprintRepo {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let prefix = "lvl-blueprint-"

    func saveBlueprint(name: String, blueprint: LevelBlueprint) throws {
        let data = try encoder.encode(blueprint)
        let url = getFileURL(from: getFileName(blueprintName: name), ext: "json")

        try data.write(to: url)
    }

    func loadBlueprint(name: String) throws -> LevelBlueprint {
        let url = getFileURL(from: getFileName(blueprintName: name), ext: "json")

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

    func getAllBlueprintNames() throws -> Set<String> {
        let files = try FileManager.default.contentsOfDirectory(at: getAppDirURL(), includingPropertiesForKeys: nil)

        let names = files
            .filter { $0.isFileURL }
            .compactMap { file in
                getBlueprintName(fromFileName: file.deletingPathExtension().lastPathComponent)
            }

        return Set(names)
    }

    private func getFileName(blueprintName: String) -> String {
        "\(prefix)\(blueprintName)"
    }

    private func getBlueprintName(fromFileName fileName: String) -> String? {
        if fileName.hasPrefix(prefix) {
            return String(fileName.dropFirst(prefix.count))
        }
        return nil
    }

    private func getFileURL(from name: String, ext: String) -> URL {
        let directory = getAppDirURL()
        return directory.appendingPathComponent(name).appendingPathExtension(ext)
    }

    private func getAppDirURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
