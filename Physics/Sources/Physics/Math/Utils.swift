//
//  Utils.swift
//  Physics

/// Clamps `value` to the given `min` and `max` values. Behavior is undefined
/// if `max` is smaller than `min`.
/// - Returns: `value` if it is between `min` or `max`.
///            `min` if `value` is smaller than `min`.
///            `max` if `value` is larger than `max`
func clamp<T: Comparable>(value: T, min: T, max: T) -> T {
    if value <= min {
        return min
    }

    if value >= max {
        return max
    }

    return value
}

func clamp<T: Comparable>(value: T, min: T?, max: T?) -> T {
    if let min = min, value <= min {
        return min
    }

    if let max = max, value >= max {
        return max
    }

    return value
}
