//
//  PowerupSelectionView.swift
//  Peggle

import SwiftUI

struct PowerupSelectionView: View {

    struct PowerupListEntry: Equatable & CustomStringConvertible {
        let powerup: Powerup

        var description: String {
            powerup.name
        }

        static func == (
            lhs: PowerupSelectionView.PowerupListEntry,
            rhs: PowerupSelectionView.PowerupListEntry
        ) -> Bool {
            lhs.powerup.name == rhs.powerup.name
        }
    }

    let availablePowerups: [Powerup]
    let powerupSelectedCallback: (Powerup) -> Void

    @State private var selectedPowerupEntry: PowerupListEntry?

    var controls: some View {
        HStack {
            Spacer()
            Button("Confirm") {
                guard let selectedPowerupEntry = selectedPowerupEntry else {
                    return
                }
                powerupSelectedCallback(selectedPowerupEntry.powerup)

            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }

    var body: some View {
        VStack {
            Text("Select a Powerup!")
                .padding()
                .font(.title)
            Selection(
                selectionItems: availablePowerups.map { PowerupListEntry(powerup: $0) },
                id: \.powerup.name,
                selectedItem: $selectedPowerupEntry
            )
            controls
        }
        .frame(maxWidth: 280, maxHeight: 320)
    }
}

 struct PowerupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PowerupSelectionView(
            availablePowerups: AllPowerups,
            powerupSelectedCallback: { _ in }
        )
    }
 }
