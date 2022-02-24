//
//  Ball+Displayable.swift
//  Peggle

import UIKit

extension Ball: Displayable {

    var viewCenter: CGPoint {
        self.center.toCGPoint()
    }

    var viewWidth: CGFloat {
        self.radius * 2
    }

    var viewHeight: CGFloat {
        self.radius * 2
    }

    var image: UIImage {
        #imageLiteral(resourceName: "Ball")
    }
}
