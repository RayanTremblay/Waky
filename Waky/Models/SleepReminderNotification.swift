import Foundation
import UserNotifications

/// Schedules a local notification 30 minutes before the user’s committed bedtime to remind them to prepare for sleep.
enum SleepReminderNotification {
    private static let reminderIdentifier = "waky_prepare_for_sleep"
    private static let reminderMinutesBefore = 30

    /// Call at app launch to request notification permission.
    static func requestPermissionIfNeeded(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    /// Schedules a reminder for (bedtime - 30 minutes). Only schedules if that time is in the future. Cancels any existing reminder first.
    static func schedulePrepareForSleep(bedtime: Date) {
        cancel()
        let fireDate = Calendar.current.date(byAdding: .minute, value: -reminderMinutesBefore, to: bedtime) ?? bedtime
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to wind down"
        content.body = "Your sleep window starts in 30 minutes. Get ready for bed."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    /// Cancels the scheduled “prepare for sleep” reminder (e.g. when the session ends).
    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }
}
