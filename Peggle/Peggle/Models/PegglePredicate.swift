//
//  PegglePredicate.swift
//  Peggle

protocol PegglePredicate {
    func test(state: PeggleState) -> Bool
}
