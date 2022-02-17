//
//  LevelDesignerView.swift
//  Peggle

import SwiftUI

struct LevelDesignerView: View {

    @EnvironmentObject var navigator: Navigator<PeggleRoute>
    @ObservedObject var appState: AppState
    @StateObject var viewModel = LevelDesignerViewModel(repo: LevelBlueprintFileRepo())

    // Controls for manipulating the level
    // ie. loading or saving the current level
    var levelControls: some View {
        HStack(spacing: 15) {
            Button("Load") { viewModel.loadLevelBlueprint() }
            Button("Save") { viewModel.saveLevelBlueprint() }
            Button("Reset", role: .destructive) { viewModel.resetLevelBlueprint() }

            TextField("Level Name", text: $viewModel.levelName)
                .border(.secondary)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 15)

            Button("Start") {
                appState.setActiveLevelBlueprint(viewModel.blueprint)
                navigator.navigateTo(route: .game)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .alert(isPresented: $viewModel.presentAlert, error: viewModel.alertError) { error in
            if let suggestion = error.recoverySuggestion {
                Button(suggestion) {}
            }
        } message: { error in
            if let failureReason = error.failureReason {
                Text(failureReason)
            }
        }
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
                    case let .addPeg(pegColor):
                        Image(uiImage: imageForPegColor(pegColor))
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
                GameBackground(width: geometry.size.width, height: geometry.size.height)
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
                if let levelBlueprint = appState.activeLevelBlueprint {
                    viewModel.blueprint = levelBlueprint
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
                    .frame(height: geometry.size.height * 0.1, alignment: .center)
                    .padding(.vertical, 5)
                levelPreview
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private func imageForPegColor(_ color: PegColor) -> UIImage {
        switch color {
        case .blue:
            return #imageLiteral(resourceName: "PegBlue")
        case .orange:
            return #imageLiteral(resourceName: "PegOrange")
        }
    }
}

struct LevelDesignerView_Previews: PreviewProvider {
    static var previews: some View {
        LevelDesignerView(appState: AppState())
    }
}
