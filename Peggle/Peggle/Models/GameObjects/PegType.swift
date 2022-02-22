//
//  PegType.swift
//  Peggle

enum PegType: CaseIterable, Hashable, Codable {
    case blue
    case orange
    case green
    
    static func isWinCondition(_ type: PegType) -> Bool {
        switch type {
        case .blue:
            return false
        case .orange:
            return true
        case .green:
            return false
        }
    }
    
    static func isPowerup(_ type: PegType) -> Bool {
        switch type {
        case .blue:
            return false
        case .orange:
            return false
        case .green:
            return true
        }
    }

}
