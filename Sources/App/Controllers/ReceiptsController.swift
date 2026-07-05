import Foundation
import Vapor
import Model
import FluentKit

class ReceiptsController: RouteCollection {
    private let networkService = QRDataParsingNetworkService()
    private let parser = SimpleProductsParser()

    func boot(routes: any Vapor.RoutesBuilder) throws {
        let receiptsRoutes = routes.grouped("receipts")

        receiptsRoutes.group("parse") { builder in
            builder.post(use: parseReceipt)
        }
    }
    
    private func parseReceipt(request: Request) async throws -> [FoodProduct] {
        guard let parsedQRData = try? request.content.decode(QRCodeRawData.self) else {
            throw CommonRequestError.unableToParseParameter(ParameterNames.qrDataInBody)
        }

        let productItems = try await networkService.sendQRCode(qrRawData: parsedQRData.qrRawString)
        return productItems.data.dataJSON.items.map { item in
            parser.parseProductItem(item: item)
        }
    }
}

private extension ReceiptsController {
    enum ParameterNames {
        static let qrDataInBody = "qr data from body"
    }
}
