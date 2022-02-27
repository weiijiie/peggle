//
//  LevelBlueprint.swift
//  Peggle

import Physics

/// LevelBlueprint represents the blueprint for a level of Peggle. It consists of a collection of
/// `ObstacleBlueprint`s laid out on top of a 2D coordinate space. The 2D coordinate
/// space is a rectangle with a maximum height and width, with the origin at the (0, 0) point.
///
/// A LevelBlueprint b has the following invariants:
/// - Every `ObstacleBlueprint` in b must not overlap with any other `ObstacleBlueprint`
///   in b, based on the defined hitboxes of the obstacles.
/// - Every `ObstacleBlueprint` in b must be fully inside the rectangle defined by the maximum
///   height and width, referred to as the "boundary" of the level.
struct LevelBlueprint {

    private(set) var obstacleBlueprints: [ObstacleBlueprint] = []

    let width: Double
    let height: Double
    let center: Point

    init(width: Double, height: Double) {
        self.obstacleBlueprints = []
        self.width = width
        self.height = height
        self.center = Point(x: width / 2, y: height / 2)
    }

    /// Adds the specified obstacle blueprint to the level blueprint. If the obstacle cannot be placed in the blueprint
    /// according to the invariants, nothing happens.
    mutating func addObstacle(_ obstacle: ObstacleBlueprint) {
        guard canPlace(obstacle: obstacle) else {
            return
        }

        obstacleBlueprints.append(obstacle)
    }

    mutating func addObstacleCenteredAt(
        point center: Point,
        color: ObstacleColor,
        interactive: Bool
    ) {
        let scaledWidth = getScaledSize(
            of: Peg.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(width)
        )

        if interactive {
            let radius = scaledWidth / 2
            let obstacle = ObstacleBlueprint.round(color: color, center: center, radius: Double(radius))
            addObstacle(obstacle)

        } else {
            let obstacle = ObstacleBlueprint.equilateralTriangle(
                color: color,
                center: center,
                sideLength: Double(scaledWidth)
            )
            addObstacle(obstacle)
        }
    }

    /// Removes the given obstacle blueprint from the level blueprint.
    mutating func removeObstacle(_ obstacle: ObstacleBlueprint) {
        obstacleBlueprints.removeAll(where: { $0 == obstacle })
    }

    /// Returns true if and only if the obstacle does not overlap with any existing obstacle,
    /// and if the obstacle is fully inside the boundary of the level.
    func canPlace(obstacle: ObstacleBlueprint) -> Bool {
        !overlapsWithExistingObstacle(obstacle) && fullyInsideBoundary(obstacle)
    }

    /// Returns true if the given obstacle overlaps with any of the existing obstacles in the blueprint.
    /// and false otherwise. Also returns true if there are currently no obstacles in the blueprint.
    private func overlapsWithExistingObstacle(_ obstacle: ObstacleBlueprint) -> Bool {
        if obstacleBlueprints.isEmpty {
            return false
        }

        return obstacleBlueprints.contains { Geometry.overlaps($0.hitBox, obstacle.hitBox) }
    }

    private var boundary: Geometry {
        .axisAlignedRectangle(center: center, width: width, height: height)
    }

    /// The edges of the level boundary are represented as an array of 4 rectangles with 0 length,
    /// running parallel along the axes.
    private var boundaryEdges: [Geometry] {
        [
            .axisAlignedRectangle(center: Point(x: 0, y: height / 2), width: 0.1, height: height),
            .axisAlignedRectangle(center: Point(x: width, y: height / 2), width: 0.1, height: height),
            .axisAlignedRectangle(center: Point(x: width / 2, y: 0), width: width, height: 0.1),
            .axisAlignedRectangle(center: Point(x: width / 2, y: height), width: width, height: 0.1)
        ]
    }

    /// Returns true if the obstacle is fully inside the level boundaries, and false otherwise.
    /// To be fully inside the level boundaries, the obstacle must overlap with the boundary,
    /// and not overlap with any of the edges of the boundary.
    private func fullyInsideBoundary(_ obstacle: ObstacleBlueprint) -> Bool {
        Geometry.overlaps(boundary, obstacle.hitBox)
             && !boundaryEdges.contains { Geometry.overlaps($0, obstacle.hitBox) }
    }
}

extension LevelBlueprint: Codable {}
