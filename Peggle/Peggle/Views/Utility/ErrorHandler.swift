//
//  ErrorHandler.swift
//  Peggle

import SwiftUI

typealias ErrorHandler = (
    modifier: ErrorHandlerModifier,
    doWithErrorHandling: (() throws -> Void) -> Void
)

func makeErrorHandler(debug: Bool = false) -> ErrorHandler {
    let errorWrapper = ErrorWrapper()
    let modfier = ErrorHandlerModifier(errorWrapper: errorWrapper, debug: debug)

    func doWithErrorHandling(action: () throws -> Void) {
        do {
            try action()
        } catch {
            errorWrapper.setError(error)
        }
    }

    return (modifier: modfier, doWithErrorHandling)
}

/// View modifier to help with handling errors.
///
/// - Usage:
/// First, create the `ErrorHandler` in any view as a instance variable, then add the modifier to
/// the view body via `.withErrorHandler(errorHandler)`.
/// Next, wrap any statement that throws with `errorHandler.doWithErrorHandling`. Any
/// error that is thrown will then show up as an alert.
struct ErrorHandlerModifier: ViewModifier {

    @ObservedObject fileprivate var errorWrapper: ErrorWrapper
    let debug: Bool

    fileprivate init(errorWrapper: ErrorWrapper, debug: Bool = false) {
        self.errorWrapper = errorWrapper
        self.debug = debug
    }

    func body(content: Content) -> some View {
        let error = errorWrapper.error
        content
            .alert(error?.localizedDescription ?? "Error", isPresented: $errorWrapper.presentAlert) {
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
        modifier(errorHandler.modifier)
    }
}

private class ErrorWrapper: ObservableObject {
    /// Casting unknown errors to NSError allows us to handle `Error`, `LocalizedError`,
    /// and `NSError`. More information here: http://www.figure.ink/blog/2021/7/18/practical-localized-error-values
    @Published var error: NSError?
    @Published var presentAlert = false

    let debug: Bool

    init(debug: Bool = true) {
        self.debug = debug
    }

    func setError(_ error: Error) {
        self.error = error as NSError
        presentAlert = true
        if debug {
            print("Error: \(self.error.debugDescription)")
        }
    }
}
