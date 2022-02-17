//
//  WorldTests.swift
//  PhysicsTests

import XCTest
@testable import Physics

class WorldTests: XCTestCase {

    // We don't require the engine to be extremely accurate
    let Epsilon: Double = 0.1

    func testGravity() {
        let world = World(
            broadPhaseCollisionDetector: MockBroadPhaseCollisionDetector(),
            collisionResolver: MockCollisionResolver()
        )

        let bodies: [(body: RigidBody, initialHeight: Double)] = [
            (
                body: makeCircleRigidBody(
                    motion: .dynamic(
                        position: Vector2D(x: 0, y: 0),
                        mass: 10
                    )
                ),
                initialHeight: 0
            ),
            (
                body: makeCircleRigidBody(
                    motion: .dynamic(
                        position: Vector2D(x: 100, y: -100),
                        mass: 100
                    )
                ),
                initialHeight: -100
            ),
            (
                body: makeCircleRigidBody(
                    motion: .dynamic(
                        position: Vector2D(x: 200, y: 100),
                        velocity: Vector2D(x: 10), // test whether independent of horizontal motion
                        mass: 50
                    )
                ),
                initialHeight: 100
            )
        ]

        for (body, _) in bodies {
            world.addRigidBody(body)
        }

        world.update(totalTime: 1, numberOfSteps: 100)

        for (body, initialHeight) in bodies {
            // Using kinematic eq: s = u * t + 1/2 * a * t^2
            // t = 1 -> 0 * 1 + 1/2 * (-9.81) * 1^2 = -4.905
            print(body.position.y)
            XCTAssertEqual(body.position.y, initialHeight - 4.905, accuracy: Epsilon,
                           "Body should have fallen ~4.905 metres after 1 second")
        }

        world.update(totalTime: 1, numberOfSteps: 100)

        for (body, initialHeight) in bodies {
            // t = 2 -> 0 * 2 + 1/2 * (-9.81) * 2^2 = -19.62
            XCTAssertEqual(body.position.y, initialHeight - 19.62, accuracy: Epsilon,
                           "Body should have fallen ~19.62 metres after 2 seconds")
        }
    }

    // swiftlint:disable function_body_length
    func testBoundaries() {
        struct TestCase {
            var minX: Double?
            var maxX: Double?
            var minY: Double?
            var maxY: Double?

            var geometries: [(geometry: Geometry, collides: Bool)]
        }

        let testCases = [
            TestCase(
                minX: 0,
                maxX: 100,
                minY: 0,
                maxY: 200,
                geometries: [
                    (
                        // same size as world, should not collide at all
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 50, y: 100),
                            width: 100,
                            height: 200
                        ),
                        collides: false
                    ),
                    (
                        // slightly larger than world, should collide
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 50, y: 100),
                            width: 100.1,
                            height: 200.1
                        ),
                        collides: true
                    )
                ]
            ),
            TestCase(
                minX: -100,
                geometries: [
                    (
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 0, y: 100),
                            width: 300,
                            height: 200
                        ),
                        collides: true
                    ),
                    (
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 1_000, y: 0),
                            width: 600,
                            height: 100_000_000
                        ),
                        collides: false
                    )
                ]
            ),
            TestCase(
                minX: -100,
                maxX: 100,
                minY: -100,
                geometries: [
                    (
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 0, y: 100_000),
                            width: 400,
                            height: 100
                        ),
                        collides: true
                    ),
                    (
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 0, y: 0),
                            width: 50,
                            height: 300
                        ),
                        collides: true
                    ),
                    (
                        geometry: Geometry.axisAlignedRectangle(
                            center: Point(x: 0, y: 100_000),
                            width: 50,
                            height: 200_000
                        ),
                        collides: false
                    )
                ]
            )
        ]

        for testCase in testCases {
            let world = World(
                broadPhaseCollisionDetector: MockBroadPhaseCollisionDetector(),
                collisionResolver: MockCollisionResolver(),
                minX: testCase.minX,
                maxX: testCase.maxX,
                minY: testCase.minY,
                maxY: testCase.maxY
            )

            for (geometry, collides) in testCase.geometries {
                let result = world.boundaries.filter { boundary in
                    Geometry.overlaps(boundary.hitBox, geometry)
                }

                XCTAssertEqual(!result.isEmpty, collides,
                               """
                               Boundaries should\(collides ? " " : "not ") collide with the geometry.
                               Boundaries Collided: \(result)
                               Geometry: \(geometry)
                               """)
            }
        }
    }

    func testBouncingBall() {
        let world = World(
            broadPhaseCollisionDetector: SpatialHash(cellSize: 10),
            // use the actual resolver as we need to test collisions
            collisionResolver: ImpulseCollisionResolver(),
            minY: 0
        )

        // We start the ball at a height of 45, with a radius of 1.
        // This means it's lowest point is at 44.
        // It should take ~3 seconds to reach the ground, as
        // u * t + 1/2 * a * t^2 = 44.145 when t = 3
        let ball = makeCircleRigidBody(
            motion: .dynamic(position: Vector2D(x: 0, y: 45),
                             velocity: Vector2D(x: 5), // constant velocity to the right
                             mass: 10),
            radius: 1
        )

        // Since we set both the ball and the boundaries to be perfectly elastic,
        // the peak height of the ball after bouncing should be roughly the
        // starting height, and it should reach that point after roughly the same
        // amount of time it took to fall.
        // Thus we create a block in the rough estimated position of that peak and
        // check if the call collides with it.
        let block = RigidBody(
            motion: .static(position: Vector2D(x: 30, y: 46.9)),
            hitBoxAt: { center in
                .axisAlignedRectangle(center: center, width: 5, height: 1)
            }
        )

        var numBallCollisions = 0
        var collidedWithBlock = false

        world.addRigidBody(ball, onCollide: { collision in
            print("\nCollided!")
            print("\(collision.body1.motion)\n")
            print("\(collision.body2.motion)\n")
            numBallCollisions += 1
        })

        world.addRigidBody(block, onCollide: { _ in collidedWithBlock = true })

        world.update(totalTime: 7, numberOfSteps: 420) // ~ 60 fps

        XCTAssertEqual(numBallCollisions, 2,
                       "Ball should have collided once with the ground and once with the block after 7 seconds")

        XCTAssertTrue(collidedWithBlock, "Ball should have collided with block")
    }
}

func makeCircleRigidBody(
    motion: Motion,
    radius: Double = 5,
    material: Material = Materials.PerfectlyElastic
) -> RigidBody {
    RigidBody(
        motion: motion,
        hitBoxAt: { center in .circle(center: center, radius: radius) },
        material: material
    )
}

extension World {
    func update(totalTime: Float, numberOfSteps: Int, callback: ((Int) -> Void)? = nil) {
        let dt = totalTime / Float(numberOfSteps)
        for i in 1...numberOfSteps {
            update(dt: dt)
            callback?(i)
        }
    }
}

struct MockBroadPhaseCollisionDetector: BroadPhaseCollisionDetector {

    typealias Object = RigidBody

    var objects: [Object.ID: Object] = [:]

    mutating func addBroadPhaseObject(_ object: RigidBody) {
        objects[object.id] = object
    }

    mutating func removeBroadPhaseObject(_ object: RigidBody) {
        objects.removeValue(forKey: object.id)
    }

    mutating func updateBroadPhaseObject(_ object: RigidBody) {
        objects[object.id] = object
    }

    func getCandidateCollisionGroups() -> [CandidateCollisionGroup] {
        [Array(objects.values)]
    }
}

struct MockCollisionResolver: CollisionResolver {
    func resolve(collision: Collision) -> Bool {
        false
    }
}
