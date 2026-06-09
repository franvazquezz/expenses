import XCTest
@testable import expenses

final class ReminderNotificationServiceTests: XCTestCase {
    func testNextTriggerDateUsesTodayWhenTimeIsStillAhead() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 6, day: 9, hour: 10, minute: 0)))

        let nextDate = ReminderNotificationService.nextTriggerDate(
            hour: 20,
            minute: 30,
            from: now,
            calendar: calendar
        )
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 9)
        XCTAssertEqual(components.hour, 20)
        XCTAssertEqual(components.minute, 30)
    }

    func testNextTriggerDateMovesToTomorrowWhenTimeAlreadyPassed() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 6, day: 9, hour: 22, minute: 0)))

        let nextDate = ReminderNotificationService.nextTriggerDate(
            hour: 20,
            minute: 30,
            from: now,
            calendar: calendar
        )
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 10)
        XCTAssertEqual(components.hour, 20)
        XCTAssertEqual(components.minute, 30)
    }
}

