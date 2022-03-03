//
//  LevelDesignerView.swift
//  Peggle

import SwiftUI

struct LevelDesignerView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @ObservedObject var appState: AppState
    @StateObject var viewModel = LevelDesignerViewModel(repo: LevelBlueprintFileRepo())

    let handler = makeErrorHandler()

    // Controls for manipulating the level
    // ie. loading or saving the current level
    var levelControls: some View {
        VStack {
            HStack {
                NavigateToMenuButton()

                Spacer()
                Text(viewModel.levelName)
                    .font(.title)
                Spacer()

                Button {
                    if let blueprint = viewModel.blueprint {
                        appState.setActiveLevelBlueprint(blueprint, name: viewModel.levelName)
                        navigator.navigateTo(route: .game)
                    }
                } label: {
                    Label("Start", systemImage: "gamecontroller.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            HStack(spacing: 24) {
                Spacer()

                Group {
                    Button("Load") { viewModel.showLevelSelect = true }
                    Button("Save") { viewModel.showSaveDialog = true }
                    Button("Reset", role: .destructive) { viewModel.resetLevelBlueprint() }
                }

                Spacer()
            }
        }
        .padding(.horizontal)
    }

    // Controls for editing the current level
    var editControls: some View {
        HStack(spacing: 15) {
            ForEach(viewModel.editModes, id: \.self) { mode in
                let opacity = viewModel.selectedMode == mode ? 1 : 0.5

                if case .removePeg = mode {
                    Spacer()
                }

                Button {
                    viewModel.selectedMode = mode
                } label: {
                    imageFor(editMode: mode)
                        .resizable()
                        .scaledToFit()
                        .opacity(opacity)
                }
                .disabled(mode == viewModel.selectedMode)
            }
        }
        .padding(.horizontal)
    }

    var cameraControls: some View {
        VStack(alignment: .center) {
            let bg = Rectangle()
                .fill(.white)
                .padding()

            if viewModel.cameraYOffSet > 0 {
                Button {
                    viewModel.panCameraUp()
                } label: {
                    Label("up", systemImage: "chevron.up.square.fill")
                        .labelStyle(.iconOnly)
                        .background(bg)
                        .font(.system(size: 54))
                }
            }
            Spacer()
            Button {
                viewModel.panCameraDown()
            } label: {
                Label("down", systemImage: "chevron.down.square.fill")
                    .labelStyle(.iconOnly)
                    .background(bg)
                    .font(.system(size: 54))
            }
        }
        .padding(.vertical)
    }

    var levelPreview: some View {
        GeometryReader { geometry in
            ZStack {
                GameBackgroundView(width: geometry.size.width, height: geometry.size.height)
                    .overlay {
                        OnTapView(tappedCallback: { tappedAt in
                            // take into account the camera offset
                            let point = CGPoint(x: tappedAt.x, y: tappedAt.y + viewModel.cameraYOffSet)
                            viewModel.tapAt(point: point)
                        })
                    }

                pegBlueprints(viewModel.placedPegs)
                cameraControls
            }
            .onAppear {
                if let (levelBlueprint, levelName) = appState.activeLevelBlueprint {
                    viewModel.blueprint = levelBlueprint
                    viewModel.blueprintName = levelName
                } else {
                    viewModel.blueprint = LevelBlueprint(width: Double(geometry.size.width),
                                                         height: Double(geometry.size.height))
                }
            }
        }
    }

    func pegBlueprints(_ pegBlueprints: [PegBlueprint]) -> some View {
        ForEach(pegBlueprints, id: \.id) { peg in
            let showEditPanelBinding = Binding(
                get: { viewModel.currEditedPegID == peg.id && viewModel.showEditPegView },
                set: { viewModel.showEditPegView = $0 }
            )

            PegBlueprintView(
                pegBlueprint: peg,
                showEditPanel: showEditPanelBinding,
                onTap: { viewModel.tapAt(peg: peg) },
                onLongPress: { viewModel.removePeg(peg) },
                onUpdate: { viewModel.tryUpdatePeg(old: peg, new: $0) }
            )
            .offset(y: -viewModel.cameraYOffSet)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack {
                    levelControls
                    editControls
                        .frame(height: geometry.size.height * 0.075, alignment: .center)
                        .padding(.vertical, 10)
                }
                .background(.white)

                levelPreview
                    .zIndex(-1)
            }
        }
        .ignoresSafeArea(.keyboard)
        .withErrorHandler(handler)
        .overlay(if: viewModel.showLevelSelect) {
            LevelSelectionView { blueprint, name in
                viewModel.blueprint = blueprint
                viewModel.blueprintName = name
                viewModel.showLevelSelect = false
            } onCancel: {
                viewModel.showLevelSelect = false
            }
        }
        .popup(isPresented: $viewModel.showSaveDialog) {
            SaveLevelDialog(show: $viewModel.showSaveDialog, name: viewModel.levelName) { name in
                handler.doWithErrorHandling {
                    try viewModel.saveLevelBlueprint(name: name)
                    viewModel.blueprintName = name
                }
            }
        }
    }

    private func imageFor(editMode: EditMode) -> Image {
        switch editMode {
        case let .addPeg(color, interactive):
            return Image(uiImage: imageForColor(color, interactive: interactive))
        case .removePeg:
            return Image("DeleteButton")
        }
    }

    private func imageForColor(_ color: PegColor, interactive: Bool) -> UIImage {
        switch (color, interactive) {
        case (.blue, true):
            return #imageLiteral(resourceName: "PegBlue")
        case (.orange, true):
            return #imageLiteral(resourceName: "PegOrange")
        case (.green, true):
            return #imageLiteral(resourceName: "PegGreen")
        case (.blue, false):
            return #imageLiteral(resourceName: "BlockBlue")
        case (.orange, false):
            return #imageLiteral(resourceName: "BlockOrange")
        case (.green, false):
            return #imageLiteral(resourceName: "BlockGreen")
        }
    }
}

struct SaveLevelDialog: View {

    @Binding var show: Bool
    @State var name: String

    let onSaveCallback: (_ name: String) -> Void

    var body: some View {
        VStack {
            TextField("Level Name", text: $name)
                .border(.secondary)
                .textFieldStyle(.roundedBorder)

            Spacer()

            HStack(alignment: .center, spacing: 24) {
                Button("Save") {
                    show = false
                    onSaveCallback(name)
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    show = false
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 240, maxHeight: 160)
    }
}

struct LevelDesignerView_Previews: PreviewProvider {
    static var previews: some View {
        LevelDesignerView(appState: AppState())
    }
}
