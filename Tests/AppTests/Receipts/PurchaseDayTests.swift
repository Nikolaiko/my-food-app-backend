import Foundation
import Testing
import Model
@testable import App

struct PurchaseDayTests {
    let parser = SimpleProductsParser()

    @Test func receiptDateTimeWinsOverQRTime() {
        let day = parser.purchaseDay(receiptDateTime: "2024-01-18T09:00:00", qrRawString: ReceiptsTestData.qrWithTime)
        #expect(day == "2024-01-18")
    }

    @Test(arguments: [
        ReceiptsTestData.qrWithTime,
        "t=20240117T112600&s=1396.33&fn=7284440700349606&i=52208&fp=1476279607&n=1",
        "s=1396.33&fn=7284440700349606&t=20240117T1126&i=52208&fp=1476279607&n=1",
    ])
    func dayFromQRTimeWithoutReceiptDateTime(qrRawString: String) {
        #expect(parser.purchaseDay(receiptDateTime: nil, qrRawString: qrRawString) == "2024-01-17")
    }

    @Test func nightPurchaseKeepsItsDay() {
        #expect(parser.purchaseDay(receiptDateTime: "2024-01-17T02:30:00", qrRawString: ReceiptsTestData.qrWithoutTime) == "2024-01-17")
        #expect(parser.purchaseDay(receiptDateTime: nil, qrRawString: "t=20240117T0230&s=1396.33") == "2024-01-17")
    }

    @Test(arguments: ["", "garbage", "2024-13-45T11:26:00", "17.01.2024 11:26"])
    func invalidReceiptDateTimeFallsBackToQRTime(receiptDateTime: String) {
        #expect(parser.purchaseDay(receiptDateTime: receiptDateTime, qrRawString: ReceiptsTestData.qrWithTime) == "2024-01-17")
    }

    @Test(arguments: [ReceiptsTestData.qrWithoutTime, "t=garbage&s=1396.33", "t=20241345T1126&s=1396.33"])
    func noDateFallsBackToTodayInUTC(qrRawString: String) throws {
        let now = try #require(ISO8601DateFormatter().date(from: "2026-09-27T23:30:00Z"))
        #expect(parser.purchaseDay(receiptDateTime: nil, qrRawString: qrRawString, now: now) == "2026-09-27")
    }

    @Test func receiptWithoutQRTimeTakesDayFromDateTime() throws {
        let json = try ReceiptsTestData.json(named: "receipt-response")
        let receipt = try JSONDecoder().decode(ReceiptData.self, from: json).data.dataJSON
        #expect(receipt.dateTime == "2024-01-17T11:26:00")
        #expect(receipt.items.count == 2)

        let day = parser.purchaseDay(receiptDateTime: receipt.dateTime, qrRawString: ReceiptsTestData.qrWithoutTime)
        let products = receipt.items.map { parser.parseProductItem(item: $0, date: day) }
        #expect(products.map(\.date) == ["2024-01-17", "2024-01-17"])
    }

    @Test func receiptWithoutDateTimeDecodes() throws {
        let json = try ReceiptsTestData.json(named: "receipt-response-without-datetime")
        let receipt = try JSONDecoder().decode(ReceiptData.self, from: json).data.dataJSON
        #expect(receipt.dateTime == nil)
        #expect(receipt.items.count == 1)
    }
}
