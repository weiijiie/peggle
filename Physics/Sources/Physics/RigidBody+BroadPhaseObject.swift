//
//  RigidBody+BroadPhaseObject.swift
//  Peggle

extension RigidBody: BroadPhaseObject {
    public var boundingBox: BoundingBox {
        switch hitBox {
        case let .circle(center, radius):
            return (
                minX: center.x - radius,
                maxX: center.x + radius,
                minY: center.y - radius,
                maxY: center.y + radius
            )

        case let .axisAlignedRectangle(center, width, height):
            return (
                minX: center.x - width / 2,
                maxX: center.x + width / 2,
                minY: center.y - height / 2,
                maxY: center.y + height / 2
            )
        }
    }
}
