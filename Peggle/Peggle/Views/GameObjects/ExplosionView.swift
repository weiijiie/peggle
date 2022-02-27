//
//  ExplosionView.swift
//  Peggle

import SwiftUI
import Foundation

struct ExplosionView: View {
    let explosion: Explosion

    var body: some View {
        let width = explosion.viewWidth
        let height = explosion.viewHeight
        ZStack {
            Circle()
                .fill(.black)
            Circle()
                .fill(.red)
                .frame(width: width - 7, height: height - 7)
            Circle()
                .fill(.orange)
                .frame(width: width - 18, height: height - 18)
            Circle()
                .fill(.yellow)
                .frame(width: width - 30, height: height - 30)
                .blur(radius: 1)
            Circle()
                .fill(.white)
                .frame(
                    width: min(width - 60, width / 2),
                    height: min(height - 60, height / 2)
                )
                .blur(radius: 3.5)
                .opacity(0.95)
        }
        .atPositionFor(explosion)
    }
}
