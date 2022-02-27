//
//  LevelDesignerViewModel.swift
//  Peggle

import SwiftUI
import Physics

class LevelDesignerViewModel: ObservableObject {
    let editModes = EditMode.allCases

    @Published var showLevelSelect = false
    @Published var showSaveDialog = false

    @Published var selectedMode = EditMode.allCases[0]

    // Must be an optional as the width and height values for the blueprint are not
    // available at initialization.
    @Published var blueprint: LevelBlueprint?
    @Published var blueprintName: String?

    var levelName: String {
        blueprintName ?? "Custom Level"
    }

    private let repo: LevelBlueprintRepo

    init(repo: LevelBlueprintRepo) {
        self.repo = repo
    }

    var placedObstacles: [ObstacleBlueprint] {
        blueprint?.obstacleBlueprints ?? []
    }

    /// Handles taps at an arbitary point on the background of the level designer.
    /// Should only be called when tapping on an empty area of the background, ie. not on obstacles.
    func tapAt(point: CGPoint) {
        switch selectedMode {
        case let .addObstacle(color, interactive):
            blueprint?.addObstacleCenteredAt(
                point: Point(cgPoint: point),
                color: color,
                interactive: interactive
            )

        // If in remove mode when tapping at a point, then the tap must be at a location
        // where there is no obstacle (if there was a obstacle, the obstacle would be tapped
        // directly andthis method should not be called). Therefore, we do not need to remove
        // anything.
        case .removeObstacle:
            break
        }
    }

    /// Handles taps on any obstacle in the level designer.
    func tapAt(obstacle: ObstacleBlueprint) {
        switch selectedMode {
        case .addObstacle:
            break // Tapping on an existing obstacle does not do anything
        case .removeObstacle:
            blueprint?.removeObstacle(obstacle)
        }
    }

    func removeObstacle(_ obstacle: ObstacleBlueprint) {
        blueprint?.removeObstacle(obstacle)
    }

    /// Given a obstacle and the coordinates of a new location, tries to place the obstacle at the new location
    /// by removing the obstacle and adding a new obstacle with the new location. If the obstacle cannot be placed
    /// at that location, this function does nothing.
    func tryMoveObstacle(_ obstacle: ObstacleBlueprint, newLocation: CGPoint) {
        let obstacleAtNewLocation = obstacle.centeredAt(point: Point(cgPoint: newLocation))

        guard let canPlace = blueprint?.canPlace(obstacle: obstacleAtNewLocation) else {
            return
        }

        if !canPlace {
            return
        }

        blueprint?.removeObstacle(obstacle)
        blueprint?.addObstacle(obstacleAtNewLocation)
    }

    func resetLevelBlueprint() {
        guard let oldBlueprint = blueprint else {
            return
        }

        blueprint = LevelBlueprint(width: oldBlueprint.width, height: oldBlueprint.height)
    }

    func saveLevelBlueprint(name: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            throw LevelDesignerError.emptyBlueprintName
        }

        guard let blueprint = blueprint else {
            throw LevelDesignerError.unexpectedIssue(msg: "Blueprint not created")
        }

        try repo.saveBlueprint(name: trimmedName, blueprint: blueprint)
    }
}

enum LevelDesignerError: LocalizedError {
    case emptyBlueprintName
    case blueprintNotFound(name: String)
    case unexpectedIssue(msg: String)

    var errorDescription: String? {
        switch self {
        case .emptyBlueprintName:
            return "Level name cannot be empty"
        case .unexpectedIssue:
            return "An unexpected issue occured"
        case .blueprintNotFound:
            return "Blueprint not found"
        }
    }

    var failureReason: String? {
        switch self {
        case .emptyBlueprintName:
            return nil
        case .unexpectedIssue(msg: let msg):
            return msg
        case .blueprintNotFound(let name):
            return #"Could not find a blueprint with the name "\#(name)""#
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .emptyBlueprintName:
            return "Enter a name and try again"
        case .unexpectedIssue:
            return "Continue"
        case .blueprintNotFound:
            return nil
        }
    }
}
