//
//  CoordinateMapper.swift
//  Peggle

import Physics

/// Defines how to map coordinates from one coordinate system to another.
protocol CoordinateMapper {
    func localToExternal(point: Point) -> Point
    func externalToLocal(point: Point) -> Point
}

/// Default convenience methods. Only the above methods need to be implemented,
/// and all implementors get the methods below for free.
extension CoordinateMapper {
    // x coordinate only
    func localToExternal(x: Double) -> Double {
        localToExternal(point: Point(x: x, y: 0)).x
    }

    func externalToLocal(x: Double) -> Double {
        externalToLocal(point: Point(x: x, y: 0)).x
    }

    // y coordinate only
    func localToExternal(y: Double) -> Double {
        localToExternal(point: Point(x: 0, y: y)).y
    }

    func externalToLocal(y: Double) -> Double {
        externalToLocal(point: Point(x: 0, y: y)).y
    }

    // vectors
    func localToExternal(vector: Vector2D) -> Vector2D {
        let point = localToExternal(point: Point(x: vector.x, y: vector.y))
        return Vector2D(x: point.x, y: point.y)
    }

    func externalToLocal(vector: Vector2D) -> Vector2D {
        let point = externalToLocal(point: Point(x: vector.x, y: vector.y))
        return Vector2D(x: point.x, y: point.y)
    }

    // geometries
    func localToExternal(geometry: Geometry) -> Geometry {
        switch geometry {
        case let .circle(center, radius):
            return .circle(
                center: localToExternal(point: center),
                radius: localToExternal(x: radius).magnitude
            )
        case let .axisAlignedRectangle(center, width, height):
            return .axisAlignedRectangle(
                center: localToExternal(point: center),
                width: localToExternal(x: width).magnitude,
                height: localToExternal(y: height).magnitude
            )
        }
    }

    func externalToLocal(geometry: Geometry) -> Geometry {
        switch geometry {
        case let .circle(center, radius):
            return .circle(
                center: externalToLocal(point: center),
                radius: externalToLocal(x: radius).magnitude
            )
        case let .axisAlignedRectangle(center, width, height):
            return .axisAlignedRectangle(
                center: externalToLocal(point: center),
                width: externalToLocal(x: width).magnitude,
                height: externalToLocal(y: height).magnitude
            )
        }
    }

    // motion
    func localToExternal(motion: Motion) -> Motion {
        switch motion {
        case let .static(position, velocity):
            return .static(
                position: localToExternal(vector: position),
                velocity: localToExternal(vector: velocity)
            )

        case let .controlled(controller: controller):
            return .controlled(
                controller: MappedMotionController(
                    controller: controller,
                    mapper: localToExternal
                )
            )

        case let .dynamic(position, velocity, force, mass):
            return .dynamic(
                position: localToExternal(vector: position),
                velocity: localToExternal(vector: velocity),
                force: localToExternal(vector: force),
                mass: mass
            )

        case let .constrained(motion, constraints):
            return .constrained(
                localToExternal(motion: motion),
                constraints: mapMotionConstraints(
                    constraint: constraints,
                    xMapper: localToExternal(x:),
                    yMapper: localToExternal(y:)
                )
            )
        }
    }

    func externalToLocal(motion: Motion) -> Motion {
        switch motion {
        case let .static(position, velocity):
            return .static(
                position: externalToLocal(vector: position),
                velocity: externalToLocal(vector: velocity)
            )

        case let .controlled(controller: controller):
            return .controlled(
                controller: MappedMotionController(
                    controller: controller,
                    mapper: externalToLocal
                )
            )

        case let .dynamic(position, velocity, force, mass):
            return .dynamic(
                position: externalToLocal(vector: position),
                velocity: externalToLocal(vector: velocity),
                force: externalToLocal(vector: force),
                mass: mass
            )

        case let .constrained(motion, constraints):
            return .constrained(
                externalToLocal(motion: motion),
                constraints: mapMotionConstraints(
                    constraint: constraints,
                    xMapper: externalToLocal(x:),
                    yMapper: externalToLocal(y:)
                )
            )
        }
    }

    private func mapMotionConstraints(
        constraint: MotionConstraints,
        xMapper: @escaping (Double) -> Double,
        yMapper: @escaping (Double) -> Double
    ) -> MotionConstraints {
        let nullableXMapper = { (x: Double?) in
            x != nil ? xMapper(x!) : nil
        }

        let nullableYMapper = { (y: Double?) in
            y != nil ? yMapper(y!) : nil
        }

        return MotionConstraints(
            positionXMagnitude: nullableXMapper(constraint.positionXMagnitude),
            positionYMagnitude: nullableYMapper(constraint.positionYMagnitude),
            velocityXMagnitude: nullableXMapper(constraint.velocityXMagnitude),
            velocityYMagnitude: nullableYMapper(constraint.velocityYMagnitude)
        )
    }

    // rigidBodies
    func localToExternal(rigidBody: RigidBody) -> RigidBody {
        RigidBody(
            motion: localToExternal(motion: rigidBody.motion),
            hitBoxAt: { center, elapsedTime in
                localToExternal(geometry: rigidBody.hitBoxAt(center, elapsedTime))
                    .withCenter(center)
            },
            material: rigidBody.material,
            elapsedTime: rigidBody.elapsedTime,
            id: rigidBody.id // preserve the id of the rigid body
        )
    }

    func externalToLocal(rigidBody: RigidBody) -> RigidBody {
        RigidBody(
            motion: externalToLocal(motion: rigidBody.motion),
            hitBoxAt: { center, elapsedTime in
                externalToLocal(geometry: rigidBody.hitBoxAt(center, elapsedTime))
                    .withCenter(center)
            },
            material: rigidBody.material,
            elapsedTime: rigidBody.elapsedTime,
            id: rigidBody.id // preserve the id of the rigid body
        )

    }
}

struct IdentityCoordinateMapper: CoordinateMapper {
    func localToExternal(point: Point) -> Point {
        point
    }

    func externalToLocal(point: Point) -> Point {
        point
    }
}

// Helper struct to help map `Motion` enum types
struct MappedMotionController: MotionController {

    private let motionController: MotionController
    private let mapper: (Vector2D) -> Vector2D

    init(controller: MotionController, mapper: @escaping (Vector2D) -> Vector2D) {
        self.motionController = controller
        self.mapper = mapper
    }

    var position: Vector2D {
        mapper(motionController.position)
    }

    var velocity: Vector2D {
        mapper(motionController.velocity)
    }

    func update(dt: Float) -> MotionController {
        MappedMotionController(
            controller: motionController.update(dt: dt),
            mapper: mapper
        )
    }
}
