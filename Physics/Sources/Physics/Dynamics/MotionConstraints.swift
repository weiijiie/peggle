//
//  MotionConstraints.swift

/// Defines constraits for the magnitude of position and velocity for a motion.
public struct MotionConstraints {
    public let positionXMagnitude: Double?

    public let positionYMagnitude: Double?

    public let velocityXMagnitude: Double?

    public let velocityYMagnitude: Double?

    public init(
        positionXMagnitude: Double? = nil,
        positionYMagnitude: Double? = nil,
        velocityXMagnitude: Double? = nil,
        velocityYMagnitude: Double? = nil
    ) {
        self.positionXMagnitude = positionXMagnitude?.magnitude
        self.positionYMagnitude = positionYMagnitude?.magnitude
        self.velocityXMagnitude = velocityXMagnitude?.magnitude
        self.velocityYMagnitude = velocityYMagnitude?.magnitude
    }

    public var positionMinX: Double? {
        negative(positionXMagnitude)
    }

    public var positionMaxX: Double? {
        positionXMagnitude
    }

    public var positionMinY: Double? {
        negative(positionYMagnitude)
    }

    public var positionMaxY: Double? {
        positionYMagnitude
    }

    public var velocityMinX: Double? {
        negative(velocityXMagnitude)
    }

    public var velocityMaxX: Double? {
        velocityXMagnitude
    }

    public var velocityMinY: Double? {
        negative(velocityYMagnitude)
    }

    public var velocityMaxY: Double? {
        velocityYMagnitude
    }

    private func negative(_ x: Double?) -> Double? {
        if let x = x {
            return -x
        }
        return nil
    }
}
