//
//  EditMode.swift
//  Peggle

enum EditMode: CaseIterable, Hashable {
    case addPeg(PegColor)
    case removePeg

    static var allCases: [EditMode] {
        var cases = PegColor.allCases.map(self.addPeg)
        cases.append(self.removePeg)
        return cases
    }
}
