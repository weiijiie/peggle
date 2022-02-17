//
//  PegView.swift
//  Peggle

import SwiftUI
import Physics

struct PegView: View {
    let peg: Peg

    var body: some View {
        Image(uiImage: peg.image)
            .resizable()
            .rotation3DEffect(
                Angle(degrees: peg.removed ? 540 : 0),
                axis: (
                    x: peg.id.isMultiple(of: 2) ? 1 : -1,
                    y: peg.id.isMultiple(of: 3) ? 1 : -1,
                    z: peg.id.isMultiple(of: 5) ? 1 : -1
                )
            )
            .frame(width: peg.width, height: peg.height)
            .position(peg.center.toCGPoint())
            .opacity(peg.removed ? 0 : 1)
            .animation(.easeIn(duration: 1), value: peg.removed)
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
