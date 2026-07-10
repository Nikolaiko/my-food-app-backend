//
//  File.swift
//  my-food-app-backend
//
//  Created by Nikolai Baklanov on 04.07.2026.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct QRDataParsingNetworkService {
    typealias Response = (data: Data, response: URLResponse)

    private let baseAddress = "https://proverkacheka.com/api/v1/check/get"
    private let token = "13676.VoJ7foniv3FFjc7i8"

    public func sendQRCode(qrRawData: String) async throws -> ReceiptData {
        guard let url = URL(string: baseAddress) else { throw CommonRequestError.urlError }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let data : Data = "token=\(token)&qrraw=\(qrRawData.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)".data(using: .utf8)!

        request.httpBody = data

        guard let result: Response = try? await URLSession.shared.data(for: request)
        else { throw CommonRequestError.emptyResponse }

        guard !result.data.isEmpty else { throw CommonRequestError.emptyResponse }
        if let error = validateStatus(response: result.response) {
            throw error
        }

        do {
            let receiptData = try JSONDecoder().decode(ReceiptData.self, from: result.data)
            return receiptData
        }
        catch { throw CommonRequestError.unableToParseParameter("Response") }
    }

    private func validateStatus(response: URLResponse?) -> CommonRequestError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .emptyResponse
        }

        switch httpResponse.statusCode {
        case 100..<200, 300..<400:
            return .wrongStatusCode(httpResponse.statusCode)
        case 400..<500:
            return .wrongStatusCode(httpResponse.statusCode)
        case 500..<600:
            return .wrongStatusCode(httpResponse.statusCode)
        default:
            return nil
        }
    }
}


