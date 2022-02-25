//
//  MenuView.swift
//  Peggle

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @ObservedObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GameBackgroundView(width: geometry.size.width, height: geometry.size.height)
                VStack(spacing: 24) {
                    Text("Peggle")
                        .font(.largeTitle)

                    Spacer()
                    Button("PLAY") {
                        navigator.navigateTo(route: .game)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("DESIGN YOUR OWN LEVEL") {
                        navigator.navigateTo(route: .levelDesigner)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(height: 0.5 * geometry.size.height, alignment: .center)
//                Image(uiImage: #imageLiteral(resourceName: "BlockBlue"))
//                    .frame(width: 200, height: 200, alignment: .center)
//                    .transformEffect(CGAffineTransform(a: 1, b: 0, c: 0.3, d: 1, tx: 0, ty: 0))
//                Image(uiImage: #imageLiteral(resourceName: "BlockBlue"))
//                    .opacity(0.5)
//                    .frame(width: 200, height: 200, alignment: .center)
            }
            .onAppear {
                appState.unsetActiveLevelBlueprint()
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(appState: AppState())
    }
}
