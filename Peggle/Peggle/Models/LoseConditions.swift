//
//  LoseCondition.swift
//  Peggle

typealias LoseCondition = PegglePredicate

typealias LoseConditions = [LoseCondition]

extension LoseConditions {
    func hasLost(state: PeggleState) -> Bool {
        self.contains { $0.test(state: state) }
    }
}

struct RanOutOfBallsLoseCondition: LoseCondition {
    func test(state: PeggleState) -> Bool {
        state.ball == nil && state.ballsRemaining <= 0
    }
}
