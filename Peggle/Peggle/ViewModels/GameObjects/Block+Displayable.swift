////
////  Block+Displayable.swift
////  Peggle
//
// import UIKit
//
// extension Block: Displayable {
//    var viewCenter: CGPoint {
//        // we need to handle the case of a triangle specially, as the center of
//        // a triangle is different from the center of the view, which is a rectangle
//        if case let .triangle(a, b, c) = self.hitBox {
//            let minX = min(a.x, b.x, c.x)
//            let minY = min(a.y, b.y, c.y)
//
//            return CGPoint(
//                x: minX + self.hitBox.width / 2,
//                y: minY + self.hitBox.height / 2
//            )
//        }
//
//        return self.center.toCGPoint()
//    }
//
//    var viewWidth: CGFloat {
//        CGFloat(self.hitBox.width)
//    }
//
//    var viewHeight: CGFloat {
//        CGFloat(self.hitBox.height)
//    }
//
//    var image: UIImage {
//        switch self.color {
//        case .blue:
//            return #imageLiteral(resourceName: "BlockBlue")
//        case .orange:
//            return #imageLiteral(resourceName: "BlockOrange")
//        case .green:
//            return #imageLiteral(resourceName: "BlockGreen")
//        }
//    }
//
// }
