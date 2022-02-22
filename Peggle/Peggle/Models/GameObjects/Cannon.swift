//
//  Cannon.swift
// Peggle

import Physics

/// A cannon that rotates back and forth, changing its firing angle. The player should
/// tap on the cannon to fire the ball in the direction of the cannon at the moment of the tap.
struct Cannon {

    static let DefaultPeriod: Float = 3.5
    static let DefaultInitialAngle: Float = 90.0
    static let DefaultMinAngle: Float = 0.0
    static let DefaultMaxAngle: Float = 180.0

    private enum Direction {
        case positive
        case negative
    }

    let size: Float
    let position: Point

    let period: Float
    let initialAngle: Degrees
    let maxAngle: Degrees
    let minAngle: Degrees
    let range: Degrees

    private(set) var currentAngle: Degrees
    private(set) var isActive: Bool

    private var direction: Direction
    private let totalRotationAngleInPeriod: Degrees

    /// Here, 0 degrees means the cannon fires the ball directly to the left, while 180 degrees
    /// means the cannon fires the ball directly to the right. 90 degrees means the cannon fires
    /// the ball directly downwards. The period of the cannon is the duration required for the
    /// cannon to rotate until it is in its original position and moving in its original direction.
    init(
        size: Float,
        position: Point,
        period: Float = Cannon.DefaultPeriod,
        initialAngle: Degrees = Cannon.DefaultInitialAngle,
        minAngle: Degrees = Cannon.DefaultMinAngle,
        maxAngle: Degrees = Cannon.DefaultMaxAngle
    ) {
        self.size = size
        self.position = position

        self.period = period
        self.initialAngle = initialAngle
        self.maxAngle = maxAngle
        self.minAngle = minAngle
        self.range = maxAngle - minAngle

        self.currentAngle = initialAngle
        self.isActive = true

        self.direction = .positive
        self.totalRotationAngleInPeriod = 2 * (maxAngle - minAngle)
    }

    /// Convenience initializer for the given level width. The cannon's position will be
    /// its default position at the top-center of a level.
    init(
        forLevelWidth levelWidth: Double,
        period: Float = Cannon.DefaultPeriod,
        initialAngle: Degrees = Cannon.DefaultInitialAngle,
        minAngle: Degrees = Cannon.DefaultMinAngle,
        maxAngle: Degrees = Cannon.DefaultMaxAngle
    ) {
        let cannonSize = getScaledSize(
            of: Cannon.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(levelWidth)
        )

        self.init(
            size: cannonSize,
            // cannon should be centered at the same position as the ball
            position: Ball.startingPointFor(levelWidth: levelWidth),
            period: period,
            initialAngle: initialAngle,
            minAngle: minAngle,
            maxAngle: maxAngle
        )
    }

    /// Steps the cannon forward by the specified time interval `dt`. Will update the current angle of the
    /// cannon based on the direction of motion. If the cannon is not active, will do nothing.
    mutating func stepForwardBy(dt: Float) {
        guard isActive else {
            return
        }

        let fractionOfPeriod = dt / period
        let angleChange = totalRotationAngleInPeriod * fractionOfPeriod

        switch direction {
        case .positive:
            var newAngle = currentAngle + angleChange
            if newAngle > maxAngle {
                let exceededAmount = newAngle - maxAngle
                newAngle = maxAngle - exceededAmount
                direction = .negative
            }

            currentAngle = newAngle

        case .negative:
            var newAngle = currentAngle - angleChange
            if newAngle < minAngle {
                let exceededAmount = minAngle - newAngle
                newAngle = minAngle + exceededAmount
                direction = .positive
            }

            currentAngle = newAngle
        }
    }

    mutating func fire() {
        isActive = false
    }

    mutating func reload() {
        isActive = true
    }
}
