//
//  LevelDesignerViewModel.swift
//  Peggle

import SwiftUI
import Physics

class LevelDesignerViewModel: ObservableObject {
    let editModes = EditMode.allCases

    @Published var selectedMode = EditMode.allCases[0]
    @Published var levelName = ""

    // Must be an optional as the width and height values for the blueprint are not
    // available at initialization.
    @Published var blueprint: LevelBlueprint?

    @Published var presentAlert = false
    @Published var alertError: LevelDesignerError?

    private let repo: LevelBlueprintRepo

    init(repo: LevelBlueprintRepo) {
        self.repo = repo
    }

    var placedPegs: [PegBlueprint] {
        blueprint?.pegBlueprints ?? []
    }

    /// Handles taps at an arbitary point on the background of the level designer.
    /// Should only be called when tapping on an empty area of the background, ie. no pegs.
    func tapAt(point: CGPoint) {
        switch selectedMode {
        case let .addPeg(color):
            blueprint?.addPegBlueprintCenteredAt(point: Point(cgPoint: point), color: color)

        // If in remove mode when tapping at a point, then the tap must be at a location
        // where there is no peg (if there was a peg, the peg would be tapped directly and
        // this method should not be called). Therefore, we do not need to remove anything.
        case .removePeg:
            break
        }
    }

    /// Handles taps on any peg in the level designer.
    func tapAt(peg: PegBlueprint) {
        switch selectedMode {
        case .addPeg:
            break // Tapping on an existing peg does not do anything
        case .removePeg:
            blueprint?.removePegBlueprint(peg)
        }
    }

    func removePeg(_ peg: PegBlueprint) {
        blueprint?.removePegBlueprint(peg)
    }

    /// Given a peg and the coordinates of a new location, tries to place the peg at the new location
    /// by removing the peg and adding a new peg with the new location. If the peg cannot be placed
    /// at that location, this function does nothing.
    func tryMovePeg(_ peg: PegBlueprint, newLocation: CGPoint) {
        let pegAtNewLocation = peg.centeredAt(point: Point(cgPoint: newLocation))

        guard let canPlace = blueprint?.canPlace(pegBlueprint: pegAtNewLocation) else {
            return
        }

        if !canPlace {
            return
        }

        blueprint?.removePegBlueprint(peg)
        blueprint?.addPegBlueprint(pegAtNewLocation)
    }

    func resetLevelBlueprint() {
        guard let oldBlueprint = blueprint else {
            return
        }

        blueprint = LevelBlueprint(width: oldBlueprint.width, height: oldBlueprint.height)
    }

    func saveLevelBlueprint() {
        tryAndSetAlertError {
            if levelName.isEmpty {
                throw LevelDesignerError.emptyBlueprintName
            }

            guard let blueprint = blueprint else {
                return
            }
                try repo.saveBlueprint(name: levelName, blueprint: blueprint)
        }
    }

    func loadLevelBlueprint() {
        tryAndSetAlertError {
            if levelName.isEmpty {
                throw LevelDesignerError.emptyBlueprintName
            }

            do {
                blueprint = try repo.loadBlueprint(name: levelName)
            } catch LevelBlueprintRepoError.blueprintNotFound(let name) {
                throw LevelDesignerError.blueprintNotFound(name: name)
            }
        }
    }

    private func tryAndSetAlertError(action: () throws -> Void) {
        do {
            try action()
        } catch let error as LevelDesignerError {
            presentAlert = true
            alertError = error
        } catch {
            presentAlert = true
            print(error)
            alertError = LevelDesignerError.unexpectedIssue(
                msg: error.localizedDescription)
        }
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
