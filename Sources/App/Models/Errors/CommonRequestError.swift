import Foundation
import Vapor

enum CommonRequestError: Error {
    case notFound
    case notAuthotized
    case unableToGetParameter(String)
    case unableToParseParameter(String)
}

extension CommonRequestError: AbortError {
    var reason: String {
        switch self {
        case .unableToGetParameter(let parameterName):
            return "Unable to get parameter: \(parameterName) from request"
        case .unableToParseParameter(let parameterName):
            return "Unable to parse parameter: \(parameterName) from request"
        case .notFound:
            return "Needed object not found"
        case .notAuthotized:
            return "Not Authorized"
        }
    }
    var status: HTTPResponseStatus {
        switch self {
        case .notAuthotized:
            return .unauthorized
        case .notFound:
            return .notFound
        case .unableToGetParameter(_),
             .unableToParseParameter(_):
            return .badRequest
        }
    }
}

