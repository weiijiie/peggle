//
//  BallView.swift
//  Peggle

import Physics
import SwiftUI

struct BallView: View {
    let ball: Ball

    var body: some View {
        DisplayableView(displayable: ball)
    }
}

struct BallView_Previews: PreviewProvider {
    static var previews: some View {
        BallView(ball: Ball(center: Point(x: 200, y: 100), radius: 10))
    }
}
