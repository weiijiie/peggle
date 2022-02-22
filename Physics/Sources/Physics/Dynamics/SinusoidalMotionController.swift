//
//  SinusoidalMotionController.swift

public struct SinusoidalMotionController: MotionController {

    private let initialPosition: Vector2D
    private let positionOffset: Vector2D
    public let velocity: Vector2D

    private let timeElapsed: Float

    public let period: Float
    public let horizontalRange: Double
    public let verticalRange: Double

    public init(
        position: Vector2D,
        period: Float,
        horizontalRange: Double = 0,
        verticalRange: Double = 0
    ) {
        self.init(
            initialPosition: position,
            positionOffset: Vector2D.Zero,
            velocity: Vector2D.Zero,
            timeElapsed: 0,
            period: period,
            horizontalRange: horizontalRange,
            verticalRange: verticalRange
        )
    }

    private init(
         initialPosition: Vector2D,
         positionOffset: Vector2D,
         velocity: Vector2D,
         timeElapsed: Float,
         period: Float,
         horizontalRange: Double,
         verticalRange: Double
    ) {
        self.initialPosition = initialPosition
        self.positionOffset = positionOffset
        self.velocity = velocity
        self.timeElapsed = timeElapsed

        self.period = period
        self.horizontalRange = horizontalRange
        self.verticalRange = verticalRange
    }

    /// The current position is based on the initial position + the position offset.
    /// The position offset is computed by the sinusoidal function and the given
    /// ranges.
    public var position: Vector2D {
        initialPosition + positionOffset
    }

    public func update(dt: Float) -> MotionController {
        let newTimeElapsed = timeElapsed + dt
        // compute the new offset factor
        let factor = sinusoidalFn(time: timeElapsed)

        // scale the factor by the appropriate ranges
        let horizontalOffset = factor * horizontalRange / 2
        let verticalOffset = factor * verticalRange / 2

        let newPositionOffset = Vector2D(x: horizontalOffset, y: verticalOffset)

        // we take the average velocity during this step, which is
        // the difference in offset over dt
        let newVelocity = (newPositionOffset - positionOffset) / dt

        return SinusoidalMotionController(
            initialPosition: initialPosition,
            positionOffset: newPositionOffset,
            velocity: newVelocity,
            timeElapsed: newTimeElapsed,
            period: period,
            horizontalRange: horizontalRange,
            verticalRange: verticalRange
        )

    }

    private func sinusoidalFn(time: Float) -> Double {
        sin(degrees: Double((time / period) * 360))
    }
}
