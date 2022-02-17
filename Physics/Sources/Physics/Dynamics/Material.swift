//
//  Material.swift
//  Peggle

public struct Material {
    let restitution: Double

    public init(restitution: Double) {
        self.restitution = restitution
    }
}

public struct Materials {
    public static let PerfectlyElastic = Material(restitution: 1)

    public static func combinedRestitutiuon(_ material1: Material, _ material2: Material) -> Double {
        // Taking the minimum of the coefficient of restitutions for 2 materials leads to
        // intuitive results when simulating.
        return min(material1.restitution, material2.restitution)
    }
}
