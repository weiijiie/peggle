//
//  ErrorHandler.swift
//  Peggle

import SwiftUI

/// View modifier to help with handling errors.
///
/// - Usage:
/// First, create the `ErrorHandler` in any view as a instance variable, then add the modifier to
/// the view body via `.withErrorHandler(errorHandler)`.
/// Next, wrap any statement that throws with `errorHandler.doWithErrorHandling`. Any
/// error that is thrown will then show up as an alert.
struct ErrorHandler: ViewModifier {

    /// Casting unknown errors to NSError allows us to handle `Error`, `LocalizedError`,
    /// and `NSError`. More information here: http://www.figure.ink/blog/2021/7/18/practical-localized-error-values
    @State private(set) var error: NSError?
    @State private(set) var presentAlert = false

    let debug: Bool

    init(debug: Bool = false) {
        self.debug = debug
    }

    func doWithErrorHandling(action: () throws -> Void) {
        do {
            try action()
        } catch {
            presentAlert = true
            self.error = error as NSError
            if debug {
                print(error)
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .alert(error?.localizedDescription ?? "Error", isPresented: $presentAlert) {
                if let suggestion = error?.localizedRecoverySuggestion {
                    Button(suggestion) {}
                }
            } message: {
                if let failureReason = error?.localizedFailureReason {
                    Text(failureReason)
                }
            }
    }
}

extension View {
    func withErrorHandler(_ errorHandler: ErrorHandler) -> some View {
        modifier(errorHandler)
    }
}
