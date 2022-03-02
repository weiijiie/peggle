//
//  PegView.swift
//  Peggle

import SwiftUI
import Physics

struct PegView: View {
    let peg: Peg

    @State private(set) var randSeed = Int.random(in: 0...10)
    @State var rotationDegrees: Double = 0
    @State var show = true

    var body: some View {
        let yOffset = peg.viewCenter.y - peg.center.y

        Image(uiImage: peg.image)
            .resizable()
            .offset(y: yOffset)
            .rotationEffect(.degrees(Double(peg.rotation)))
            .rotation3DEffect(
                Angle(degrees: rotationDegrees),
                axis: (
                    x: randSeed.isMultiple(of: 2) ? 1 : -1,
                    y: randSeed.isMultiple(of: 3) ? 1 : -1,
                    z: randSeed.isMultiple(of: 5) ? 1 : -1
                )
            )
            .frame(width: peg.viewWidth, height: peg.viewHeight)
            .scaleEffect(peg.scale)
            .position(peg.center.toCGPoint())
            .opacity(show ? 1 : 0)
            .onChange(of: peg) { newValue in
                if newValue.removed {
                    withAnimation(.easeIn(duration: 1)) {
                        rotationDegrees += 360
                        show = false
                    }
                } else {
                    show = true
                }
            }
    }
}

struct PegView_Previews: PreviewProvider {
    static var previews: some View {
        PegView(peg: Peg(
            color: .blue,
            hitBox: .circle(center: Point(x: 100, y: 100), radius: 10),
            rotation: 0,
            scale: 1,
            interactive: false
        ))
    }
}
