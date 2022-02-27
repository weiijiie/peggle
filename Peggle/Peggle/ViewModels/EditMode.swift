//
//  EditMode.swift
//  Peggle

enum EditMode: CaseIterable, Hashable {
    case addObstacle(color: ObstacleColor, interactive: Bool)
    case removeObstacle

    static var allCases: [EditMode] {
        var cases = ObstacleColor.allCases.map { addObstacle(color: $0, interactive: true) } +
            ObstacleColor.allCases.map { addObstacle(color: $0, interactive: false) }
        cases.append(self.removeObstacle)
        return cases
    }
}
