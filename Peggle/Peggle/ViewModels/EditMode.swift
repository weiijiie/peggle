//
//  EditMode.swift
//  Peggle

enum EditMode: CaseIterable, Hashable {
    case addPeg(color: PegColor, interactive: Bool)
    case removePeg

    static var allCases: [EditMode] {
        var cases = PegColor.allCases.map { addPeg(color: $0, interactive: true) } +
            PegColor.allCases.map { addPeg(color: $0, interactive: false) }
        cases.append(self.removePeg)
        return cases
    }
}
