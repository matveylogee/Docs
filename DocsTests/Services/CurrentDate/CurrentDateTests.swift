import XCTest
@testable import Docs

final class CurrentDateTests: XCTestCase {
    
    private var sut: CurrentDateProtocol!
    private var enUSPosixDateFormatter: DateFormatter!
    private var enUSPosixTimestampFormatter: DateFormatter!
    private var enUSPosixTimeFormatter: DateFormatter!
    private var enUSPosixDateOnlyFormatter: DateFormatter!
    private var calendar: Calendar!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = CurrentDate()
        
        enUSPosixDateFormatter = DateFormatter()
        enUSPosixDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        enUSPosixDateFormatter.dateFormat = "dd/MM/yy"
        
        enUSPosixTimestampFormatter = DateFormatter()
        enUSPosixTimestampFormatter.locale = Locale(identifier: "en_US_POSIX")
        enUSPosixTimestampFormatter.dateFormat = "dd/MM/yy HH:mm"
        
        enUSPosixTimeFormatter = DateFormatter()
        enUSPosixTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        enUSPosixTimeFormatter.dateFormat = "HH:mm"
        
        enUSPosixDateOnlyFormatter = DateFormatter()
        enUSPosixDateOnlyFormatter.locale = Locale(identifier: "en_US_POSIX")
        enUSPosixDateOnlyFormatter.dateFormat = "dd/MM/yy"
        
        calendar = Calendar.current
    }
    
    override func tearDownWithError() throws {
        sut = nil
        enUSPosixDateFormatter = nil
        enUSPosixTimestampFormatter = nil
        enUSPosixTimeFormatter = nil
        enUSPosixDateOnlyFormatter = nil
        calendar = nil
        try super.tearDownWithError()
    }
    
    /// 1) Проверяем, что pdfCreateData() действительно возвращает сегодняшнюю дату в формате "dd/MM/yy"
    func testPdfCreateData_ReturnsTodayDateOnly() {
        let now = Date()
        let expectedDateString = enUSPosixDateFormatter.string(from: now)
        
        let result = sut.pdfCreateData()
        
        XCTAssertEqual(
            result,
            expectedDateString,
            "Ожидали, что pdfCreateData() вернёт сегодняшнюю дату (\(expectedDateString)), " +
            "а получили \(result)"
        )
    }
    
    /// 2) Проверяем, что pdfCreateTimestamp() возвращает сегодняшнюю дату и время в формате "dd/MM/yy HH:mm"
    func testPdfCreateTimestamp_ReturnsTodayDateAndTime() {
        let now = Date()
        let expectedTimestamp = enUSPosixTimestampFormatter.string(from: now)
        
        let result = sut.pdfCreateTimestamp()
        
        XCTAssertEqual(
            result,
            expectedTimestamp,
            "Ожидали, что pdfCreateTimestamp() вернёт текущие дату+время (\(expectedTimestamp)), " +
            "а получили \(result)"
        )
    }
    
    /// 3) Если передать строку сегодняшней даты-времени, pdfDisplayDate вернёт только время ("HH:mm")
    func testPdfDisplayDate_FromTodayDateTimeString_ReturnsTimePart() {
        let now = Date()
        let inputString = enUSPosixTimestampFormatter.string(from: now) // "dd/MM/yy HH:mm"
        let expectedTime = enUSPosixTimeFormatter.string(from: now)      // "HH:mm"
        
        let displayed = sut.pdfDisplayDate(from: inputString)
        
        XCTAssertEqual(
            displayed,
            expectedTime,
            "Ожидали, что для даты-времени сегодня pdfDisplayDate вернёт только время (\(expectedTime)), " +
            "а получили \(displayed)"
        )
    }
    
    /// 4) Если передать строку «вчерашнего» времени, pdfDisplayDate вернёт "Yesterday"
    func testPdfDisplayDate_FromYesterdayDateTimeString_ReturnsYesterday() {
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else {
            return XCTFail("Не удалось вычислить дату «вчера»")
        }
        
        let inputString = enUSPosixTimestampFormatter.string(from: yesterday)
        let displayed = sut.pdfDisplayDate(from: inputString)
        
        XCTAssertEqual(
            displayed,
            "Yesterday",
            "Ожидали, что для вчерашней даты-времени pdfDisplayDate вернёт \"Yesterday\", а получили \(displayed)"
        )
    }
    
    /// 5) Если передать строку из позапрошлого (или любого более раннего, чем вчера) дня,
    ///    pdfDisplayDate вернёт только дату ("dd/MM/yy"), без времени.
    func testPdfDisplayDate_FromOlderThanYesterday_ReturnsDateOnly() {
        guard let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date()) else {
            return XCTFail("Не удалось вычислить дату «2 дня назад»")
        }

        let inputString = enUSPosixTimestampFormatter.string(from: twoDaysAgo)
        let expectedDateOnly = enUSPosixDateOnlyFormatter.string(from: twoDaysAgo)
        let displayed = sut.pdfDisplayDate(from: inputString)
        
        XCTAssertEqual(
            displayed,
            expectedDateOnly,
            "Ожидали, что для даты позапрошлого дня pdfDisplayDate вернёт только дату (\(expectedDateOnly)), " +
            "а получили \(displayed)"
        )
    }
    
    /// 6) Если строка на входе не соответствует формату "dd/MM/yy HH:mm", pdfDisplayDate просто вернёт её как есть
    func testPdfDisplayDate_FromInvalidString_ReturnsOriginal() {
        let invalidInput = "not-a-date"
        
        let displayed = sut.pdfDisplayDate(from: invalidInput)
        
        XCTAssertEqual(
            displayed,
            invalidInput,
            "Ожидали, что при передаче невалидной строки pdfDisplayDate вернёт её unchanged, " +
            "а получили \(displayed)"
        )
    }
}
