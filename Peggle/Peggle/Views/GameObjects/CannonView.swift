//
//  CannonView.swift
//  Peggle

import SwiftUI
import Physics

struct CannonView: View {

    let cannon: Cannon
    let onTapCallback: ((Cannon) -> Void)?

    init(cannon: Cannon, onTapCallback: ((Cannon) -> Void)? = nil) {
        self.cannon = cannon
        self.onTapCallback = onTapCallback
    }

    var body: some View {
        Image(uiImage: cannon.image)
            .resizable()
            .rotationEffect(SwiftUI.Angle(degrees: Double(cannon.imageRotation)), anchor: .center)
            .frame(width: cannon.width, height: cannon.height)
            .position(x: cannon.position.x, y: cannon.position.y)
            .opacity(cannon.isActive ? 1 : 0.2)
            .animation(.easeIn(duration: 0.4), value: cannon.isActive)
            .onTapGesture {
                if cannon.isActive {
                    onTapCallback?(cannon)
                }
            }
    }
}

struct CannonView_Previews: PreviewProvider {
    static var previews: some View {
        CannonView(cannon: Cannon(forLevelWidth: 800, period: 3.5))
    }
}
