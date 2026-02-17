import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func scheduleNotification(for habit: Habit, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Час для звички! 🎯"
        content.body = "\(habit.name) - не забудьте виконати!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Помилка налаштування нагадування: \(error)")
            }
        }
    }
    
    func cancelNotification(for habitID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitID.uuidString])
    }
    
    func updateNotification(for habit: Habit, at time: Date?) {
        cancelNotification(for: habit.id)
        
        if let time = time {
            scheduleNotification(for: habit, at: time)
        }
    }
}
