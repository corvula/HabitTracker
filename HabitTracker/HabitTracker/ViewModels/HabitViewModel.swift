import Foundation
import Combine

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            saveHabits()
        }
    }
    
    let healthKitManager = HealthKitManager()
    
    init() {
        loadHabits()
        healthKitManager.requestAuthorization()
    }
    
    func toggleHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        if habits[index].isCompletedToday() {
            habits[index].completedDates.removeAll { Calendar.current.isDateInToday($0) }
        } else {
            habits[index].completedDates.append(Date())
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
    
    func syncHealthKitData() {
        for (index, habit) in habits.enumerated() {
            guard habit.isHealthKitLinked, let type = habit.healthKitType else { continue }
            
            healthKitManager.checkTodayData(for: type) { hasData in
                if hasData && !self.habits[index].isCompletedToday() {
                    self.habits[index].completedDates.append(Date())
                }
            }
        }
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habits")
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
}
