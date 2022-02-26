//
//  PegBlueprint+Displayable.swift
//  Peggle

import UIKit

extension PegBlueprint: Displayable {

    var viewCenter: CGPoint {
        self.center.toCGPoint()
    }

    var viewWidth: CGFloat {
        CGFloat(self.hitBox.width)
    }

    var viewHeight: CGFloat {
        CGFloat(self.hitBox.height)
    }

    var image: UIImage {
        switch (self.type, self.isInteractive) {
        case (.blue, true):
            return #imageLiteral(resourceName: "PegBlue")
        case (.orange, true):
            return #imageLiteral(resourceName: "PegOrange")
        case (.green, true):
            return #imageLiteral(resourceName: "PegGreen")
        case (.blue, false):
            return #imageLiteral(resourceName: "BlockBlue")
        case (.orange, false):
            return #imageLiteral(resourceName: "BlockOrange")
        case (.green, false):
            return #imageLiteral(resourceName: "BlockGreen")
        }
    }
}
