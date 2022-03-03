//
//  PegBlueprintView.swift
//  Peggle

import SwiftUI
import Physics

struct PegBlueprintView: View {

    let pegBlueprint: PegBlueprint

    var showEditPanel: Binding<Bool>

    let onTap: () -> Void
    let onLongPress: () -> Void
    /// Callback that will be called when the peg blueprint is edited
    /// by the user. Should return true if the update is "accepted", by
    /// the parent component, and false otherwise.
    let onUpdate: (PegBlueprint) -> Bool

    @State var isEditing = false
    @State var rotation: Degrees
    @State var scale: Double

    @GestureState var dragLocation: CGPoint?

    init(
        pegBlueprint: PegBlueprint,
        showEditPanel: Binding<Bool>,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void,
        onUpdate: @escaping (PegBlueprint) -> Bool
    ) {
        self.pegBlueprint = pegBlueprint
        self.showEditPanel = showEditPanel
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.onUpdate = onUpdate

        self._rotation = State(initialValue: pegBlueprint.rotation)
        self._scale = State(initialValue: pegBlueprint.scale)
    }

    func peg(
        at position: CGPoint,
        rotation: Degrees? = nil,
        scale: Double? = nil
    ) -> some View {
        // since the actual center and the view center are not aligned if the hitbox
        // is a triangle, naively rotating leads to odd rotations. instead we
        // incorporate a y offset to fix the rotation
        let yOffset = pegBlueprint.viewCenter.y - pegBlueprint.hitBox.center.y

        return Image(uiImage: pegBlueprint.image)
            .resizable()
            .offset(y: yOffset)
            .rotationEffect(.degrees(Double(rotation ?? pegBlueprint.rotation)))
            .frame(width: pegBlueprint.viewWidth, height: pegBlueprint.viewHeight)
            .scaleEffect(scale ?? pegBlueprint.scale)
            .position(position)
    }

    var body: some View {
        // hide the actual peg and show the preview if being dragtged or edited
        let opacity = dragLocation != nil || isEditing ? 0.0 : 1.0

        peg(at: pegBlueprint.center.toCGPoint())
            .opacity(opacity)
            .onTapGesture(perform: onTap)
            .onLongPressGesture(perform: onLongPress)
            .gesture(
                DragGesture()
                    .updating($dragLocation) { value, location, _ in
                        location = value.location
                    }.onEnded { value in
                        let updatedPeg = pegBlueprint
                            .centeredAt(point: Point(cgPoint: value.location))
                        _ = onUpdate(updatedPeg)
                    }
            )

        if showEditPanel.wrappedValue {
            EditPegView(
                pegBlueprint: pegBlueprint,
                show: showEditPanel,
                isEditing: $isEditing,
                rotation: $rotation,
                scale: $scale,
                onUpdate: onUpdate
            )
            .zIndex(1)
        }

        // while dragging, show a preview of the peg at the dragged location
        if let dragLocation = dragLocation {
            peg(at: dragLocation)
                .opacity(0.5)
                .zIndex(1) // show this preview above other pegs
        }

        if isEditing {
            peg(at: pegBlueprint.center.toCGPoint(), rotation: rotation, scale: scale)
                .opacity(0.5)
                .zIndex(1) // show this preview above other pegs
        }
    }
}

struct PegBlueprintView_Previews: PreviewProvider {
    @State static var show = false

    static var previews: some View {
        PegBlueprintView(
            pegBlueprint: PegBlueprint.round(color: .blue, center: Point(x: 250, y: 250), radius: 30),
            showEditPanel: $show,
            onTap: {},
            onLongPress: {},
            onUpdate: { _ in true }
        )
    }
}
