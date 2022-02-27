//
//  WinCondition.swift
//  Peggle

typealias WinCondition = PegglePredicate

typealias WinConditions = [WinCondition]

extension WinConditions {
    func hasWon(state: PeggleState) -> Bool {
        self.contains { $0.test(state: state) }
    }
}

struct ClearAllOrangePegsWinCondition: WinCondition {
    func test(state: PeggleState) -> Bool {
        // checks if there are no pegs that are orange and not removed
        !state.pegs.values.contains { $0.isWinCondition() && !$0.removed }
    }
}
