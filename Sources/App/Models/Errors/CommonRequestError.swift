import Foundation
import Vapor

enum CommonRequestError: Error {
    case notFound
    case notAuthotized
    case urlError
    case emptyResponse
    case wrongStatusCode(Int)
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
        case .urlError:
            return "Error parsing url"
        case .emptyResponse:
            return "No data"
        case .wrongStatusCode(let code):
            return "Wrong response status: \(code)"
        }
    }
    var status: HTTPResponseStatus {
        switch self {
        case .notAuthotized:
            return .unauthorized
        case .notFound:
            return .notFound
        case .unableToGetParameter(_), .unableToParseParameter(_):
            return .badRequest
        case .urlError, .emptyResponse:
            return .internalServerError
        case .wrongStatusCode(let code):
            return HTTPResponseStatus(statusCode: code)
        }
    }
}

