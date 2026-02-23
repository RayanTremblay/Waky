import Foundation
import UserNotifications

/// Schedules local notifications before the user’s committed bedtime to remind them their sleep session is approaching and to wind down.
enum SleepReminderNotification {
    private static let approachingIdentifier = "waky_sleep_session_approaching"
    private static let windDownIdentifier = "waky_wind_down"
    private static let windDownMinutesBefore = 30
    private static let approachingMinutesBefore = 60

    /// Call to request notification permission. Shows the system alert if status is not yet determined.
    static func requestPermissionIfNeeded(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    /// Current authorization status (use to show in-app prompt or open Settings).
    static func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    /// Schedules reminders for the next occurrence of this bedtime (hour:minute). Use when the user has confirmed a bedtime but hasn't started a session — they'll get reminders even before committing.
    static func schedulePrepareForSleepForNextOccurrence(bedtime: Date) {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: bedtime)
        guard let next = calendar.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTime) else { return }
        schedulePrepareForSleep(bedtime: next)
    }

    /// Schedules reminders before the given bedtime (use the "Fall asleep by" time the user selected on the home screen). One reminder at 1 hour before, one at 30 min. Cancels any existing reminders first. Notifications will be delivered when the trigger fires if the user has granted permission by then.
    static func schedulePrepareForSleep(bedtime: Date) {
        cancel()
        let calendar = Calendar.current
        let now = Date()

        // 1 hour before: "Sleep session approaching"
        let approachingDate = calendar.date(byAdding: .minute, value: -approachingMinutesBefore, to: bedtime) ?? bedtime
        if approachingDate > now {
            let content = UNMutableNotificationContent()
            content.title = "Sleep session approaching"
            content.body = "Your sleep session starts in about an hour. Start winding down when you can."
            content.sound = .default
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: approachingDate)
            components.second = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: approachingIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }

        // 30 minutes before: "Get ready to wind down"
        let windDownDate = calendar.date(byAdding: .minute, value: -windDownMinutesBefore, to: bedtime) ?? bedtime
        if windDownDate > now {
            let content = UNMutableNotificationContent()
            content.title = "Time to wind down"
            content.body = "Your sleep session starts in 30 minutes. Get ready for bed and open Waky when you're ready to sleep."
            content.sound = .default
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: windDownDate)
            components.second = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: windDownIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    /// Cancels all scheduled sleep reminders (e.g. when the session ends or is cancelled).
    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            approachingIdentifier,
            windDownIdentifier,
            "waky_prepare_for_sleep" // legacy
        ])
    }
}
