import Foundation
import Vapor

enum CommonRequestError: Error {
    case notFound
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
        }
    }
    var status: HTTPResponseStatus {
        switch self {
        case .notFound:
            return .notFound
        case .unableToGetParameter(_),
             .unableToParseParameter(_):
            return .badRequest
        }
    }
}

