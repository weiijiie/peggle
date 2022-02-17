//
//  Trigonometry.swift
//  Peggle

import Foundation

// from: https://stackoverflow.com/a/28600210
func sin(degrees: Double) -> Double {
    __sinpi(degrees / 180.0)
}

func cos(degrees: Double) -> Double {
    __cospi(degrees / 180.0)
}
