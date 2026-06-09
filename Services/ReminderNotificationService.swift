import Foundation
import UserNotifications

enum ReminderNotificationService {
    static let notificationIdentifier = "daily-entry-reminder"

    static func nextTriggerDate(
        hour: Int,
        minute: Int,
        from date: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        let normalizedHour = min(max(hour, 0), 23)
        let normalizedMinute = min(max(minute, 0), 59)
        let today = calendar.date(
            bySettingHour: normalizedHour,
            minute: normalizedMinute,
            second: 0,
            of: date
        ) ?? date

        if today > date {
            return today
        }

        return calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }

    static func sync(isEnabled: Bool, hour: Int, minute: Int) async {
        if isEnabled {
            await schedule(hour: hour, minute: minute)
        } else {
            cancel()
        }
    }

    static func schedule(hour: Int, minute: Int) async {
        let center = UNUserNotificationCenter.current()
        let granted = await requestAuthorization(center: center)

        guard granted else {
            cancel(center: center)
            return
        }

        let normalizedHour = min(max(hour, 0), 23)
        let normalizedMinute = min(max(minute, 0), 59)
        let content = UNMutableNotificationContent()
        content.title = "Cargar movimientos"
        content.body = "Revisa si tenes gastos o ingresos para registrar hoy."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = normalizedHour
        dateComponents.minute = normalizedMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        do {
            try await center.add(request)
        } catch {
            cancel(center: center)
        }
    }

    static func cancel(center: UNUserNotificationCenter = .current()) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }

    private static func requestAuthorization(center: UNUserNotificationCenter) async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }
}
