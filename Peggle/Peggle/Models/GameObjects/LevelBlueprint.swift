//
//  LevelBlueprint.swift
//  Peggle

import Physics

/// LevelBlueprint represents the blueprint for a level of Peggle. It consists of a collection of `Peg`s laid
/// out on top of a 2D coordinate space. The 2D coordinate space is a rectangle with a maximum height
/// and width, with the origin at the (0, 0) point.
///
/// A LevelBlueprint b has the following invariants:
/// - Every `Peg` in b must not overlap with any other `Peg` in b, based on the defined hitboxes
///   of the pegs.
/// - Every `Peg` in b must be fully inside the rectangle defined by the maximum height and width,
///   referred to as the "boundary" of the level.
struct LevelBlueprint {
    private(set) var pegBlueprints: [PegBlueprint]
    let width: Double
    let height: Double
    let center: Point

    init(width: Double, height: Double) {
        self.pegBlueprints = []
        self.width = width
        self.height = height
        self.center = Point(x: width / 2, y: height / 2)
    }

    /// Adds the specified peg blueprint to the level blueprint. If the peg cannot be placed in the blueprint
    /// according to the invariants, nothing happens.
    mutating func addPegBlueprint(_ pegBlueprint: PegBlueprint) {
        guard canPlace(pegBlueprint: pegBlueprint) else {
            return
        }

        pegBlueprints.append(pegBlueprint)
    }

    mutating func addPegBlueprintCenteredAt(point center: Point, color: PegColor) {
        let pegRadius = getScaledSize(
            of: PegBlueprint.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(width)
        ) / 2

        let peg = PegBlueprint.round(color: color, center: center, radius: Double(pegRadius))
        addPegBlueprint(peg)
    }

    /// Removes the given peg blueprint from the level blueprint.
    mutating func removePegBlueprint(_ pegBlueprint: PegBlueprint) {
        pegBlueprints.removeAll(where: { $0 == pegBlueprint })
    }

    /// Returns true if and only if the peg does not overlap with any existing peg,
    /// and if the peg is fully inside the boundary of the level.
    func canPlace(pegBlueprint: PegBlueprint) -> Bool {
        !overlapsWithExistingPeg(pegBlueprint) && fullyInsideBoundary(pegBlueprint)
    }

    /// Returns true if the given peg overlaps with any of the existing pegs in the blueprint.
    /// and false otherwise. Also returns true if there are currently no pegs in the blueprint.
    private func overlapsWithExistingPeg(_ peg: PegBlueprint) -> Bool {
        if pegBlueprints.isEmpty {
            return false
        }

        return pegBlueprints.contains { Geometry.overlaps($0.hitBox, peg.hitBox) }
    }

    private var boundary: Geometry {
        .axisAlignedRectangle(center: center, width: width, height: height)
    }

    /// The edges of the level boundary are represented as an array of 4 rectangles with 0 length,
    /// running parallel along the axes.
    private var boundaryEdges: [Geometry] {
        [
            .axisAlignedRectangle(center: Point(x: 0, y: height / 2), width: 0, height: height),
            .axisAlignedRectangle(center: Point(x: width, y: height / 2), width: 0, height: height),
            .axisAlignedRectangle(center: Point(x: width / 2, y: 0), width: width, height: 0),
            .axisAlignedRectangle(center: Point(x: width / 2, y: height), width: width, height: 0)
        ]
    }

    /// Returns true if the peg is fully inside the level boundaries, and false otherwise.
    /// To be fully inside the level boundaries, the peg must overlap with the boundary,
    /// and not overlap with any of the edges of the boundary.
    private func fullyInsideBoundary(_ pegBlueprint: PegBlueprint) -> Bool {
        Geometry.overlaps(boundary, pegBlueprint.hitBox)
            && !boundaryEdges.contains { Geometry.overlaps($0, pegBlueprint.hitBox) }
    }
}

extension LevelBlueprint: Codable {}
