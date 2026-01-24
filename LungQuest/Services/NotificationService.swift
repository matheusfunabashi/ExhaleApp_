import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Request Authorization
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Schedule Daily Check-in Reminder
    func scheduleCheckInReminder() {
        // Remove existing check-in notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyCheckInReminder"])
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for your daily check-in! 📝"
        content.body = "Take a moment to reflect on your progress and stay strong."
        content.sound = .default
        content.badge = 1
        content.userInfo = ["type": "checkIn"]
        
        // Schedule for 6 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 18 // 6 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyCheckInReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling check-in notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Schedule Daily Reading Reminder
    func scheduleReadingReminder() {
        // Remove existing reading notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReadingReminder"])
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Complete today's reading! 📚"
        content.body = "Learn something new to support your journey today."
        content.sound = .default
        content.badge = 1
        content.userInfo = ["type": "reading"]
        
        // Schedule for 8 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReadingReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reading notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Cancel Specific Notifications
    func cancelCheckInReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyCheckInReminder"])
    }
    
    func cancelReadingReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReadingReminder"])
    }
    
    // MARK: - Update Notifications Based on Completion
    func updateNotifications(checkInCompleted: Bool, readingCompleted: Bool) {
        // If check-in is completed, cancel the reminder for today
        // (It will still schedule for tomorrow)
        if checkInCompleted {
            // The notification is already scheduled for daily, so it will check again tomorrow
            // We could cancel today's if we wanted, but since it's a daily repeating notification,
            // it's simpler to just let it fire and the user can dismiss it
        }
        
        if readingCompleted {
            // Same for reading
        }
    }
    
    // MARK: - Setup All Notifications
    func setupNotifications() {
        requestAuthorization()
        scheduleCheckInReminder()
        scheduleReadingReminder()
    }
}
