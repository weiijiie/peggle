//
//  Explosion+Displayable.swift
//  Peggle

import UIKit

 extension Explosion: Positionable {

     var viewCenter: CGPoint {
         self.center.toCGPoint()
     }

    var viewWidth: CGFloat {
        self.radius * 2
    }

    var viewHeight: CGFloat {
        self.radius * 2
    }
 }
