//
//  PegBlueprintView.swift
//  Peggle

import SwiftUI
import Physics

struct PegBlueprintView: View {
    @State var pegBlueprint: PegBlueprint

    let onTap: () -> Void
    let onLongPress: () -> Void
    let onDragEnd: (_ endLocation: CGPoint) -> Void

    @GestureState var dragLocation: CGPoint?

    var body: some View {
        // since the actual center and the view center are not aligned if the hitbox
        // is a triangle, naively rotating leads to odd rotations. instead we
        // incorporate a y offset to fix the rotation
        let yOffset = pegBlueprint.viewCenter.y - pegBlueprint.hitBox.center.y

        Image(uiImage: pegBlueprint.image)
            .resizable()
            .offset(y: yOffset)
            .rotationEffect(.degrees(Double(pegBlueprint.rotation)))
            .frame(width: pegBlueprint.viewWidth, height: pegBlueprint.viewHeight)
            .position(x: pegBlueprint.viewCenter.x, y: pegBlueprint.viewCenter.y - yOffset)
            // hide the actual peg while dragging so only the preview is seen
            .opacity(dragLocation == nil ? 1 : 0)
            .onTapGesture(perform: onTap)
            .onLongPressGesture(perform: onLongPress)
            .gesture(
                DragGesture()
                    .updating($dragLocation) { value, location, _ in
                        location = value.location
                    }.onEnded { value in
                        onDragEnd(value.location)
                    }
            )

        VStack {
            HStack(spacing: 12) {
                Label("Rotation", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
                    .foregroundColor(.gray)
                    .font(.headline)
                Slider(value: $pegBlueprint.rotation, in: 0...360)
            }
        }
        .padding()
        .frame(width: 300, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: .gray.opacity(0.75), radius: 10)
        )
        .position(x: pegBlueprint.center.x + 180, y: pegBlueprint.center.y)

        // while dragging, show a preview of the peg at the dragged location
        if let dragLocation = dragLocation {
            Image(uiImage: pegBlueprint.image)
                .resizable()
                .frame(width: pegBlueprint.viewWidth, height: pegBlueprint.viewHeight)
                .position(dragLocation)
                .opacity(0.5)
                .zIndex(1) // show this preview above other pegs
        }
    }
}

struct PegBlueprintView_Previews: PreviewProvider {
    static var previews: some View {
        PegBlueprintView(
            pegBlueprint: PegBlueprint.round(color: .blue, center: Point(x: 250, y: 250), radius: 30),
            onTap: {},
            onLongPress: {},
            onDragEnd: { _ in }
        )
    }
}
