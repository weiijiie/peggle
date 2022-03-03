//
//  LevelBlueprint.swift
//  Peggle

import Physics

/// LevelBlueprint represents the blueprint for a level of Peggle. It consists of a collection of
/// `PegBlueprint`s laid out on top of a 2D coordinate space. The 2D coordinate
/// space is a rectangle with a maximum height and width, with the origin at the (0, 0) point.
/// The height of the coordinate space can be adjusted by the user to accomodate scrolling levels.
///
/// A LevelBlueprint b has the following invariants:
/// - Every `PegBlueprint` in b must not overlap with any other `PegBlueprint`
///   in b, based on the defined hitboxes of the pegs.
/// - Every `PegBlueprint` in b must be fully inside the rectangle defined by the maximum
///   height and width, referred to as the "boundary" of the level.
struct LevelBlueprint {

    private(set) var pegBlueprints: [PegBlueprint.ID: PegBlueprint]

    let width: Double

    // the minimum height should be fixed to the initial height value, but the
    // height should be mutable to accomodate scrolling levels.
    let minHeight: Double
    var height: Double

    init(width: Double, height: Double) {
        self.pegBlueprints = [:]
        self.width = width
        self.minHeight = height
        self.height = height
    }

    /// Returns the appropriate height after taking into account the actual current height and the minimum height.
    var resolvedHeight: Double {
        max(minHeight, height)
    }

    /// We limit the actual gameplay height to a certain distance away from the lowest peg. The rationale is that
    /// in practice, there is not much point having a large empty area below the lowest peg. If we limit the height
    /// in this manner, players have a more intuitive way of reducing a level's height (simply deleting pegs that
    /// are low will cause the game's height to shrink to match).
    var gameplayHeight: Double {
        let highestPoint = pegBlueprints.values
            .map { $0.center.y + $0.hitBox.height / 2 }
            .max()

        guard let highestPoint = highestPoint else {
            return resolvedHeight
        }

        // we use 0.3 * minHeight as a reasonable distance away from the lowest peg.
        return max(minHeight, min(height, highestPoint + 0.3 * minHeight))
    }

    var center: Point {
        Point(x: width / 2, y: resolvedHeight / 2)
    }

    /// Adds the specified peg blueprint to the level blueprint. If the peg cannot be placed in the blueprint
    /// according to the invariants, nothing happens.
    mutating func addPeg(_ peg: PegBlueprint) {
        guard canPlace(peg: peg) else {
            return
        }

        pegBlueprints[peg.id] = peg
    }

    mutating func addPegCenteredAt(
        point center: Point,
        color: PegColor,
        interactive: Bool
    ) {
        let scaledWidth = getScaledSize(
            of: Peg.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(width)
        )

        if interactive {
            let radius = scaledWidth / 2
            let peg = PegBlueprint.round(color: color, center: center, radius: Double(radius))
            addPeg(peg)

        } else {
            let peg = PegBlueprint.equilateralTriangle(
                color: color,
                center: center,
                sideLength: Double(scaledWidth)
            )
            addPeg(peg)
        }
    }

    /// Removes the given peg blueprint from the level blueprint.
    mutating func removePeg(_ peg: PegBlueprint) {
        pegBlueprints.removeValue(forKey: peg.id)
    }

    /// Returns true if and only if the peg does not overlap with any existing peg,
    /// and if the peg is fully inside the boundary of the level.
    func canPlace(peg: PegBlueprint) -> Bool {
        !overlapsWithExistingPeg(peg) && fullyInsideBoundary(peg)
    }

    /// Returns true if the given peg overlaps with any of the existing pegs in the blueprint.
    /// and false otherwise. Also returns true if there are currently no pegs in the blueprint.
    private func overlapsWithExistingPeg(_ peg: PegBlueprint) -> Bool {
        if pegBlueprints.isEmpty {
            return false
        }

        return pegBlueprints.values.contains { Geometry.overlaps($0.hitBox, peg.hitBox) }
    }

    private var boundary: Geometry {
        .axisAlignedRectangle(center: center, width: width, height: resolvedHeight)
    }

    /// The edges of the level boundary are represented as an array of 4 rectangles with 0 length,
    /// running parallel along the axes.
    private var boundaryEdges: [Geometry] {
        [
            .axisAlignedRectangle(
                center: Point(x: 0, y: resolvedHeight / 2),
                width: 0.1,
                height: resolvedHeight
            ),
            .axisAlignedRectangle(
                center: Point(x: width, y: resolvedHeight / 2),
                width: 0.1,
                height: resolvedHeight
            ),
            .axisAlignedRectangle(
                center: Point(x: width / 2, y: 0),
                width: width,
                height: 0.1
            ),
            .axisAlignedRectangle(
                center: Point(x: width / 2, y: resolvedHeight),
                width: width,
                height: 0.1
            )
        ]
    }

    /// Returns true if the peg is fully inside the level boundaries, and false otherwise.
    /// To be fully inside the level boundaries, the peg must overlap with the boundary,
    /// and not overlap with any of the edges of the boundary.
    private func fullyInsideBoundary(_ peg: PegBlueprint) -> Bool {
        Geometry.overlaps(boundary, peg.hitBox)
             && !boundaryEdges.contains { Geometry.overlaps($0, peg.hitBox) }
    }
}

extension LevelBlueprint: Codable {}
