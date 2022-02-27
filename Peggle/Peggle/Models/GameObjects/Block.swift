////
////  Block.swift
////  Peggle
//
// import Physics
// import Foundation
//
// struct Block: Equatable, Identifiable, Removable {
//
//    let id = UUID()
//
//    let color: ObstacleColor
//    let hitBox: Geometry
//
//    private(set) var hasBeenHit = false
//    private(set) var removed = false
//
//    init(color: ObstacleColor, hitBox: Geometry) {
//        self.color = color
//        self.hitBox = hitBox
//    }
//
//    var center: Point {
//        hitBox.center
//    }
//
//    mutating func hit() {
//        hasBeenHit = true
//    }
//
//    mutating func remove() {
//        removed = true
//    }
//
//    func makeRigidBody() -> RigidBody {
//        let initialPosition = Vector2D(x: center.x, y: center.y)
//        return RigidBody(
//            motion: .static(position: initialPosition),
//            hitBoxAt: { center, _ in hitBox.withCenter(center) }
//        )
//    }
// }
