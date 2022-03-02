//
//  Peg+Displayable.swift
//  Peggle

import UIKit

extension Peg: Displayable {

    var viewCenter: CGPoint {
        // we need to handle the case of a triangle specially, as the center of
        // a triangle is different from the center of the view, which is a rectangle
        if case let .triangle(a, b, c) = self.initialHitBox {
            let minX = min(a.x, b.x, c.x)
            let minY = min(a.y, b.y, c.y)

            return CGPoint(
                x: minX + self.initialHitBox.width / 2,
                y: minY + self.initialHitBox.height / 2
            )
        }

        return self.center.toCGPoint()
    }

    var viewWidth: CGFloat {
        CGFloat(self.initialHitBox.width)
    }

    var viewHeight: CGFloat {
        CGFloat(self.initialHitBox.height)
    }

    var image: UIImage {
        let litUp = self.interactive && self.hasBeenHit

        switch (self.color, self.hitBox, litUp) {
        case (.blue, .circle, false):
            return #imageLiteral(resourceName: "PegBlue")
        case (.blue, .circle, true):
            return #imageLiteral(resourceName: "PegBlueGlow")
        case (.orange, .circle, false):
            return #imageLiteral(resourceName: "PegOrange")
        case (.orange, .circle, true):
            return #imageLiteral(resourceName: "PegOrangeGlow")
        case (.green, .circle, false):
            return #imageLiteral(resourceName: "PegGreen")
        case (.green, .circle, true):
            return #imageLiteral(resourceName: "PegGreenGlow")

        case (.blue, .triangle, false):
            return #imageLiteral(resourceName: "BlockBlue")
        case (.blue, .triangle, true):
            return #imageLiteral(resourceName: "BlockBlueGlow")
        case (.orange, .triangle, false):
            return #imageLiteral(resourceName: "BlockOrange")
        case (.orange, .triangle, true):
            return #imageLiteral(resourceName: "BlockOrangeGlow")
        case (.green, .triangle, false):
            return #imageLiteral(resourceName: "BlockGreen")
        case (.green, .triangle, true):
            return #imageLiteral(resourceName: "BlockGreenGlow")

        case (_, .axisAlignedRectangle, _):
            // placeholder image since we do not support rectangular pegs
            return UIImage(systemName: "xmark.octagon")!
        }
    }
}
