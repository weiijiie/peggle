//
//  PeggleGameStatus.swift
//  Peggle

enum PeggleGameStatus {
    case ongoing
    case won
    case lost

    func isGameOver() -> Bool {
        switch self {
        case .ongoing:
            return false
        case .won:
            return true
        case .lost:
            return true
        }
    }

    static func getStatusFor(
        state: PeggleState,
        winConditions: WinConditions,
        loseConditions: LoseConditions
    ) -> PeggleGameStatus {

        if winConditions.hasWon(state: state) {
            return .won
        } else if loseConditions.hasLost(state: state) {
            return .lost
        } else {
            return .ongoing
        }
    }
}
