//
//  MotionController.swift

public protocol MotionController {
    var position: Vector2D { get }
    var velocity: Vector2D { get }

    func update(dt: Float) -> MotionController
}
