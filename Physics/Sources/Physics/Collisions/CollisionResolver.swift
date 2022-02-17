//
//  CollisionResolver.swift
//  Peggle

public protocol CollisionResolver {
    /// `resolve` should resolve the given collision by mutating the `RigidBody`s in the
    /// collision object such that their trajectory will change away from each other in the next time steps.
    /// - Returns: True if the `RigidBody`s were changed, and false otherwise (ie. if no changes
    ///            are required to resolve the collisions.
    func resolve(collision: Collision) -> Bool
}
