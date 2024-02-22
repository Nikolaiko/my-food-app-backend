import Foundation
import Vapor

enum ParsingError: Error {
    case errorParsingEnumRawValue
}

extension ParsingError: AbortError {
    var status: HTTPResponseStatus { .internalServerError }
}
