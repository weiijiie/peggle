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
        switch self.type {
        case .blue:
            return #imageLiteral(resourceName: "PegBlue")
        case .orange:
            return #imageLiteral(resourceName: "PegOrange")
        case .green:
            return #imageLiteral(resourceName: "PegGreen")
        }
    }
}
