//
//  LevelDesignerViewModel.swift
//  Peggle

import SwiftUI
import Physics

class LevelDesignerViewModel: ObservableObject {
    let editModes = EditMode.allCases

    @Published var showLevelSelect = false
    @Published var showSaveDialog = false

    @Published var selectedMode = EditMode.allCases[0] {
        didSet { currEditedPegID = nil }
    }

    // Must be an optional as the width and height values for the blueprint are not
    // available at initialization.
    @Published var blueprint: LevelBlueprint?
    @Published var blueprintName: String?

    @Published var currEditedPegID: PegBlueprint.ID?

    var levelName: String {
        blueprintName ?? "Custom Level"
    }

    private let repo: LevelBlueprintRepo

    init(repo: LevelBlueprintRepo) {
        self.repo = repo
    }

    var placedPegs: [PegBlueprint] {
        guard let blueprint = blueprint else {
            return []
        }

        return Array(blueprint.pegBlueprints.values)
    }

    /// Handles taps at an arbitary point on the background of the level designer.
    /// Should only be called when tapping on an empty area of the background, ie. not on pegs.
    func tapAt(point: CGPoint) {
        // dismiss peg editors
        currEditedPegID = nil

        switch selectedMode {
        case let .addPeg(color, interactive):
            blueprint?.addPegCenteredAt(
                point: Point(cgPoint: point),
                color: color,
                interactive: interactive
            )

        // If in remove mode when tapping at a point, then the tap must be at a location
        // where there is no peg (if there was a peg, the peg would be tapped
        // directly and this method should not be called). Therefore, we do not need to remove
        // anything.
        case .removePeg:
            break
        }
    }

    /// Handles taps on any peg in the level designer.
    func tapAt(peg: PegBlueprint) {
        switch selectedMode {
        case .addPeg:
            currEditedPegID = peg.id
        case .removePeg:
            blueprint?.removePeg(peg)
        }
    }

    func removePeg(_ peg: PegBlueprint) {
        blueprint?.removePeg(peg)
    }

    /// Given a peg and the coordinates of a new location, tries to place the peg at the new location
    /// by removing the peg and adding a new peg with the new location. If the peg cannot be placed
    /// at that location, this function does nothing.
    func tryMovePeg(_ peg: PegBlueprint, newLocation: CGPoint) {
        let pegAtNewLocation = peg.centeredAt(point: Point(cgPoint: newLocation))

        // Remove the original peg momentarily to check if the new peg can be placed
        removePeg(peg)

        guard let canPlace = blueprint?.canPlace(peg: pegAtNewLocation), canPlace else {
            // if it cannot be placed, then we re-add the original peg
            blueprint?.addPeg(peg)
            return
        }

        blueprint?.addPeg(pegAtNewLocation)
    }

    func tryUpdatePeg(old: PegBlueprint, new: PegBlueprint) {
        // Remove the original peg momentarily to check if the new peg can be placed
        removePeg(old)

        guard let canPlace = blueprint?.canPlace(peg: new), canPlace else {
            // if the new peg cannot be placed, then we re-add the original peg
            print("cant place")
            blueprint?.addPeg(old)
            return
        }

        blueprint?.addPeg(new)
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
