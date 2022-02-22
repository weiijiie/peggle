//
//  Bucket.swift
//  Peggle

import Physics

typealias BucketRigidBodies = (leftEdge: RigidBody, rightEdge: RigidBody, inside: RigidBody)

struct Bucket {
    static let DefaultPeriod: Float = 6

    // Approximate ratios for the dimensions of the bucket, compared to the
    // width of the middle of the bucket
    static let TopOverMidWidthRatio: Double = 8 / 7
    static let BottomOverMidWidthRatio: Double = 6 / 7
    static let EdgeWidthToMidWidthRatio: Double = 1 / 12
    static let HeightToWidthRatio: Double = 9 / 7

    let midWidth: Double
    var position: Point

    let period: Float
    let horizontalRange: Double

    init(
        midWidth: Double,
        position: Point,
        horizontalRange: Double,
        period: Float = Bucket.DefaultPeriod
    ) {
        self.midWidth = midWidth
        self.position = position
        self.period = period
        self.horizontalRange = horizontalRange
    }

    init(
        forLevelWidth levelWidth: Double,
        forLevelHeight levelHeight: Double,
        period: Float = Bucket.DefaultPeriod
    ) {
        // Returns the approximate width of the middle of the bucket
        let bucketMidWidth = getScaledSize(
            of: Bucket.relativeWidth,
            relativeTo: LevelBlueprint.relativeWidth,
            withActualSize: Float(levelWidth)
        )

        let initialPosition = Point(
            // start in the center
            x: levelWidth / 2,
            y: levelHeight
        )

        let horizontalRange = levelWidth - Double(bucketMidWidth)

        self.init(
            midWidth: Double(bucketMidWidth),
            position: initialPosition,
            horizontalRange: horizontalRange
        )
    }

    var topWidth: Double {
        midWidth * Bucket.TopOverMidWidthRatio
    }

    var bottomWidth: Double {
        midWidth * Bucket.BottomOverMidWidthRatio
    }

    var edgeWidth: Double {
        midWidth * Bucket.EdgeWidthToMidWidthRatio
    }

    var bucketHeight: Double {
        midWidth * Bucket.HeightToWidthRatio
    }

    mutating func updatePosition(_ position: Point) {
        self.position = position
    }

    /// A bucket can be simulated by using three rigid bodies: 2 solid rigid bodies for the left and
    /// right edges, and a passthrough rigid body for the inside
    func makeRigidBodies() -> BucketRigidBodies {
        let initialPosition = Vector2D(x: position.x, y: position.y)

        // the center x coordinate must be offset such that it is in the center of
        // the edges. we divide by 3 instead of 2 to avoid floating point issues
        let leftEdge = makeEdgeRigidBody(
            initialPosition: initialPosition,
            horizontalOffset: -(topWidth / 2) + (edgeWidth / 3)
        )
        let rightEdge = makeEdgeRigidBody(
            initialPosition: initialPosition,
            horizontalOffset: (topWidth / 2) - (edgeWidth / 3)
        )
        let inside = makeInsideRigidBody(initialPosition: initialPosition)

        return (leftEdge, rightEdge, inside)
    }

    private func makeBucketMotion(initialPosition: Vector2D) -> Motion {
        let motionController = SinusoidalMotionController(
            position: initialPosition,
            period: period,
            horizontalRange: horizontalRange
        )

        return Motion.controlled(controller: motionController)
    }

    private func makeInsideRigidBody(initialPosition: Vector2D) -> RigidBody {
        RigidBody(
            motion: makeBucketMotion(initialPosition: initialPosition),
            hitBoxAt: { center in
                .axisAlignedRectangle(
                    center: center,
                    // insides should span the top width, but not include the 2 edges
                    width: topWidth - 2 * edgeWidth,
                    // have the actual height be slightly smaller so that the ball has
                    // to be somewhat in the bucket before a collision is detected
                    height: bucketHeight * 0.7
                )
            },
            material: .passthrough
        )
    }

    private func makeEdgeRigidBody(initialPosition: Vector2D, horizontalOffset: Double) -> RigidBody {
        let adjustedPosition = Vector2D(
            x: initialPosition.x + horizontalOffset,
            y: initialPosition.y
        )

        return RigidBody(
            motion: makeBucketMotion(initialPosition: adjustedPosition),
            hitBoxAt: { center in
                .axisAlignedRectangle(
                    center: Point(x: center.x + horizontalOffset, y: center.y),
                    width: edgeWidth,
                    height: bucketHeight
                )
            }
        )
    }
}
