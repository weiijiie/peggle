//
//  EditMode.swift
//  Peggle

enum EditMode: CaseIterable, Hashable {
    case addPeg(PegType)
    case removePeg

    static var allCases: [EditMode] {
        var cases = PegType.allCases.map(self.addPeg)
        cases.append(self.removePeg)
        return cases
    }
}
