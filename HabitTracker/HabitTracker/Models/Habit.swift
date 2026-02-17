import Foundation

enum HabitPriority: String, Codable, CaseIterable {
    case low = "Низький"
    case medium = "Середній"
    case high = "Високий"
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high: return "arrow.up.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "34C759"
        case .medium: return "FF9500"
        case .high: return "FF3B30"
        }
    }
}

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var completedDates: [Date]
    var isHealthKitLinked: Bool
    var healthKitType: HealthKitDataType?
    var priority: HabitPriority
    var notes: String
    var reminderTime: Date?
    var isReminderEnabled: Bool
    
    init(id: UUID = UUID(), name: String, icon: String, color: String, isHealthKitLinked: Bool = false, healthKitType: HealthKitDataType? = nil, priority: HabitPriority = .medium, notes: String = "", reminderTime: Date? = nil, isReminderEnabled: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.completedDates = []
        self.isHealthKitLinked = isHealthKitLinked
        self.healthKitType = healthKitType
        self.priority = priority
        self.notes = notes
        self.reminderTime = reminderTime
        self.isReminderEnabled = isReminderEnabled
    }
    
    func isCompletedToday() -> Bool {
        guard let lastDate = completedDates.last else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    var currentStreak: Int {
        var streak = 0
        var date = Date()
        
        for _ in 0..<365 {
            if completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                streak += 1
                date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return streak
    }
    
    var bestStreak: Int {
        guard !completedDates.isEmpty else { return 0 }
        
        let sortedDates = completedDates.sorted()
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let prevDate = sortedDates[i-1]
            let currentDate = sortedDates[i]
            
            if Calendar.current.isDate(currentDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: prevDate)!) {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else if !Calendar.current.isDate(currentDate, inSameDayAs: prevDate) {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    func completionRate(days: Int = 30) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else { return 0 }
        
        let completedInPeriod = completedDates.filter { $0 >= startDate && $0 <= endDate }
        return Double(completedInPeriod.count) / Double(days) * 100
    }
}
