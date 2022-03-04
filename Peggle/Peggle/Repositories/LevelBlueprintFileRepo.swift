//
//  LevelBlueprintFileRepo.swift
//  Peggle

import Foundation
import UIKit

/// Dictionary of all the preloaded levels for the game. We force unwrap the optional here as we want
/// to fail-fast if the assets do not exist to catch it earlier in development.
let PreloadedLevels = [
    "Pyramids Galore": NSDataAsset(name: "PyramidsGaloreLevel")!,
    "Bubbles": NSDataAsset(name: "BubblesLevel")!,
    "Pinball": NSDataAsset(name: "PinballLevel")!
]

/// Implementation of `LevelBlueprintRepo` that saves the blueprints as JSON encoded files.
class LevelBlueprintFileRepo: LevelBlueprintRepo {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let prefix = "lvl-blueprint-"

    func saveBlueprint(name: String, blueprint: LevelBlueprint) throws {
        if PreloadedLevels[name] != nil {
            throw LevelBlueprintFileRepoError.overridePreloadedLevel(name: name)
        }

        let data = try encoder.encode(blueprint)
        print(String(data: data, encoding: .utf8)!)
        let url = getFileURL(from: getFileName(blueprintName: name), ext: "json")

        try data.write(to: url)
    }

    func loadBlueprint(name: String) throws -> LevelBlueprint {
        do {
            let data = try loadDataForBlueprint(name: name)
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

        var names = files
            .filter { $0.isFileURL }
            .compactMap { file in
                getBlueprintName(fromFileName: file.deletingPathExtension().lastPathComponent)
            }

        names.append(contentsOf: PreloadedLevels.keys)

        return Set(names)
    }

    private func loadDataForBlueprint(name: String ) throws -> Data {
        if let preloadedLevel = PreloadedLevels[name] {
            return preloadedLevel.data
        }

        let url = getFileURL(from: getFileName(blueprintName: name), ext: "json")
        return try Data(contentsOf: url)
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

enum LevelBlueprintFileRepoError: LocalizedError {
    case overridePreloadedLevel(name: String)

    var errorDescription: String? {
        switch self {
        case let .overridePreloadedLevel(name):
            return #""\#(name)" is a preloaded level, cannot save a level with that name."#
        }
    }

    var failureReason: String? {
        switch self {
        case .overridePreloadedLevel:
            return "Overriding a preloaded level"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .overridePreloadedLevel:
            return "Try using another name"
        }
    }
}
