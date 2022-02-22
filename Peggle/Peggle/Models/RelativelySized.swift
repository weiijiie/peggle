//
//  RelativelySized.swift
//  Peggle

/// This protocol allows for various game objects to be sized relative to each other. This helps
/// the game be view agnostic, as all game objects can be relatively sized based on the actual
/// level size.
///
/// Since Peggle is played on views that can have different aspect ratios, we do not
/// define the relative size in 2 dimensions, as that would lead to warped aspect ratios for some
/// game objects. Instead, we prefer that Peggle be played on portrait oriented views, and we
/// compare the relative sizes of game objects by their width, which is the more limiting axis for
/// portrait oriented views.
protocol RelativelySized {
    static var relativeWidth: Float { get }
}

func getScaledSize(of: Float, relativeTo: Float, withActualSize actualSize: Float) -> Float {
    let multiplier = of / relativeTo
    return actualSize * multiplier
}

// arbitrarily set to 100
private let levelWidth: Float = 100

// All the extensions for `RelativelySized` objects are here to make it
// easy to compare and edit in one place.

extension LevelBlueprint: RelativelySized {
    static var relativeWidth: Float {
        levelWidth
    }
}

extension PegBlueprint: RelativelySized {
    static var relativeWidth: Float {
        levelWidth * 0.06
    }
}

extension Cannon: RelativelySized {
    static var relativeWidth: Float {
        levelWidth * 0.15
    }
}

extension Ball: RelativelySized {
    static var relativeWidth: Float {
        levelWidth * 0.05
    }
}

extension Bucket: RelativelySized {
    static var relativeWidth: Float {
        levelWidth * 0.15
    }
}
