//
//  BroadPhaseCollisionDetector.swift
//  Peggle

public protocol BroadPhaseCollisionDetector {
    associatedtype Object: BroadPhaseObject

    typealias CandidateCollisionGroup = [Object]

    /// Adds the `BroadPhaseObject` to the collision detector. Should do nothing if the
    /// object has already been added before.
    mutating func addBroadPhaseObject(_ object: Object)

    /// Removes the `BroadPhaseObject` from the collision detector. Should do nothing
    /// if the object has not been added.
    mutating func removeBroadPhaseObject(_ object: Object)

    /// Updates the location of the `BroadPhaseObject` in the collision detector. If the
    /// object has not been added to the collision detector before, should add it.
    mutating func updateBroadPhaseObject(_ object: Object)

    func getCandidateCollisionGroups() -> [CandidateCollisionGroup]
}
