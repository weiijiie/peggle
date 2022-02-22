//
//  Material.swift
//  Peggle

//public struct Material {
//    let restitution: Double
//
//    public init(restitution: Double) {
//        self.restitution = restitution
//    }
//}

public enum Material {
    case solid(restitution: Double)
    case passthrough
}

public struct Materials {
    public static let PerfectlyElasticSolid: Material = .solid(restitution: 1)

}
