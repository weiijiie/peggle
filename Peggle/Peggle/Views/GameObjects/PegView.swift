//
//  PegView.swift
//  Peggle

import SwiftUI
import Physics

struct PegView: View {
    let peg: Peg

    @State var rotationDegrees: Double = 0
    @State var show = true

    var body: some View {
        Image(uiImage: peg.image)
            .resizable()
            .rotation3DEffect(
                Angle(degrees: rotationDegrees),
                axis: (
                    x: peg.id.isMultiple(of: 2) ? 1 : -1,
                    y: peg.id.isMultiple(of: 3) ? 1 : -1,
                    z: peg.id.isMultiple(of: 5) ? 1 : -1
                )
            )
            .frame(width: peg.width, height: peg.height)
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
            id: 5,
            blueprint: PegBlueprint.round(color: .blue,
                                          center: Point(x: 400, y: 200),
                                          radius: 10))
        )
    }
}
