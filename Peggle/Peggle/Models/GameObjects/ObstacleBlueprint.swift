//
// ObstacleBlueprint.swift
//  Peggle

import Physics
import Foundation

/// Obstacles are game objects that can be placed on levels to obstruct the movement of the ball.
/// They include both pegs (which have other gameplay effects), and blocks, which only serve to
/// obstruct the ball.
struct ObstacleBlueprint {
    let hitBox: Geometry
    let center: Point

    let color: ObstacleColor
    let interactive: Bool

    private init(color: ObstacleColor, interactive: Bool, hitBox: Geometry) {
        self.color = color
        self.interactive = interactive
        self.hitBox = hitBox
        self.center = hitBox.center
    }

    /// Round obstacles are considered to be interactive
    static func round(color: ObstacleColor, center: Point, radius: Double) -> ObstacleBlueprint {
        let hitBox = Geometry.circle(center: center, radius: radius)
        return self.init(color: color, interactive: true, hitBox: hitBox)
    }

    /// Triangular obstacles are consiered to not be interactive
    static func triangle(
        color: ObstacleColor,
        a: Point, b: Point, c: Point
    ) -> ObstacleBlueprint {
        let hitBox = Geometry.triangle(a, b, c)
        return self.init(color: color, interactive: false, hitBox: hitBox)
    }

    static func equilateralTriangle(color: ObstacleColor, center: Point, sideLength: Double) -> ObstacleBlueprint {
        let a = Point(x: center.x, y: center.y - (sqrt(3) / 3) * sideLength)
        let b = Point(x: center.x - sideLength / 2, y: center.y + (sqrt(3) / 6) * sideLength)
        let c = Point(x: center.x + sideLength / 2, y: center.y + (sqrt(3) / 6) * sideLength)

        return ObstacleBlueprint.triangle(color: color, a: a, b: b, c: c)
    }

    func centeredAt(point newCenter: Point) -> ObstacleBlueprint {
        ObstacleBlueprint(
            color: color,
            interactive: interactive,
            hitBox: hitBox.withCenter(newCenter)
        )
    }
}

extension ObstacleBlueprint: Equatable, Codable {}
