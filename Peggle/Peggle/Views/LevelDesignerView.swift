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

                Button {
                    viewModel.selectedMode = mode
                } label: {
                    switch mode {
                    case let .addPeg(pegType):
                        Image(uiImage: imageForPegType(pegType))
                            .resizable()
                            .scaledToFit()
                            .opacity(opacity)

                    case .removePeg:
                        Spacer()
                        Image("DeleteButton")
                            .resizable()
                            .scaledToFit()
                            .opacity(opacity)
                    }
                }
                .disabled(mode == viewModel.selectedMode)
            }
        }
        .padding(.horizontal)
    }

    var levelPreview: some View {
        GeometryReader { geometry in
            ZStack {
                GameBackgroundView(width: geometry.size.width, height: geometry.size.height)
                    .overlay(OnTapView(tappedCallback: viewModel.tapAt))

                ForEach(viewModel.placedPegs, id: \.center) { peg in
                    PegBlueprintView(
                        pegBlueprint: peg,
                        onTap: { viewModel.tapAt(peg: peg) },
                        onLongPress: { viewModel.removePeg(peg) },
                        onDragEnd: { location in
                            viewModel.tryMovePeg(peg, newLocation: location)
                        }
                    )
                }
            }
            .onAppear {
                if let (levelBlueprint, levelName) = appState.activeLevelBlueprint {
                    viewModel.blueprint = levelBlueprint
                    viewModel.blueprintName = levelName
                } else {
                    viewModel.blueprint = LevelBlueprint(
                        width: Double(geometry.size.width),
                        height: Double(geometry.size.height)
                    )
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                levelControls
                editControls
                    .frame(height: geometry.size.height * 0.075, alignment: .center)
                    .padding(.vertical, 5)
                levelPreview
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

    private func imageForPegType(_ type: PegType) -> UIImage {
        switch type {
        case .blue:
            return #imageLiteral(resourceName: "PegBlue")
        case .orange:
            return #imageLiteral(resourceName: "PegOrange")
        case .green:
            return #imageLiteral(resourceName: "PegGreen")
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
