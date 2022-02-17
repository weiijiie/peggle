//
//  BallView.swift
//  Peggle

import Physics
import SwiftUI

struct BallView: View {
    let ball: Ball

    var body: some View {
        Image(uiImage: ball.image)
            .resizable()
            .frame(width: ball.width, height: ball.height)
            .position(ball.center.toCGPoint())
    }
}

struct BallView_Previews: PreviewProvider {
    static var previews: some View {
        BallView(ball: Ball(center: Point(x: 200, y: 100), radius: 10))
    }
}
