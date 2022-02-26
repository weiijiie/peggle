//
//  PegType.swift
//  Peggle

enum PegType: CaseIterable, Hashable, Codable {
    case blue
    case orange
    case green

    func isWinCondition() -> Bool {
        switch self {
        case .blue:
            return false
        case .orange:
            return true
        case .green:
            return false
        }
    }

    func isPowerup() -> Bool {
        switch self {
        case .blue:
            return false
        case .orange:
            return false
        case .green:
            return true
        }
    }
}
