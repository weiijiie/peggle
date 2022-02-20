// swiftlint:disable:this file_name
//
//  Trigonometry.swift
//  Physics

import Foundation

public typealias Degrees = Float

// from: https://stackoverflow.com/a/28600210
public func sin(degrees: Double) -> Double {
    __sinpi(degrees / 180.0)
}

public func cos(degrees: Double) -> Double {
    __cospi(degrees / 180.0)
}
