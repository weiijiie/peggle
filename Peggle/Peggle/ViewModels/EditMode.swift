//
//  EditMode.swift
//  Peggle

enum EditMode: CaseIterable, Hashable {
    case addPeg(type: PegType, isInteractive: Bool)
    case removePeg

    static var allCases: [EditMode] {
        var cases = PegType.allCases.map { addPeg(type: $0, isInteractive: true) } +
            PegType.allCases.map { addPeg(type: $0, isInteractive: false) }
        cases.append(self.removePeg)
        return cases
    }
}
