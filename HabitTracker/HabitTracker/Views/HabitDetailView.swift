import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    statsSection
                    calendarSection
                    weekChartSection
                    
                    if !habit.notes.isEmpty {
                        notesSection
                    }
                }
                .padding()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var headerSection: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: habit.color))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Label(habit.priority.rawValue, systemImage: habit.priority.icon)
                    .font(.caption)
                    .foregroundColor(Color(hex: habit.priority.color))
                
                if habit.isHealthKitLinked {
                    Label("HealthKit", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    var statsSection: some View {
        VStack(spacing: 12) {
            Text("Статистика")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Поточна серія",
                    value: "\(habit.currentStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Найкраща серія",
                    value: "\(habit.bestStreak)",
                    icon: "trophy.fill",
                    color: .yellow
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Всього днів",
                    value: "\(habit.completedDates.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Виконання",
                    value: String(format: "%.0f%%", habit.completionRate()),
                    icon: "chart.bar.fill",
                    color: .blue
                )
            }
        }
    }
    
    var calendarSection: some View {
        VStack(spacing: 12) {
            Text("Календар")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CalendarView(completedDates: habit.completedDates, accentColor: Color(hex: habit.color))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    var weekChartSection: some View {
        VStack(spacing: 12) {
            Text("Останні 7 днів")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            WeekChartView(completedDates: habit.completedDates, color: Color(hex: habit.color))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Нотатки")
                .font(.headline)
            
            Text(habit.notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CalendarView: View {
    let completedDates: [Date]
    let accentColor: Color
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 8) {
            // Дні тижня
            HStack {
                ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Нд"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Сітка днів
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isCompleted: isDateCompleted(date),
                            isToday: calendar.isDateInToday(date),
                            accentColor: accentColor
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    var daysInMonth: [Date?] {
        let today = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        var days: [Date?] = []

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let emptyDays = (firstWeekday + 5) % 7 // Понеділок = 0
        days.append(contentsOf: Array(repeating: nil, count: emptyDays))

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        completedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let accentColor: Color
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .font(.caption)
            .fontWeight(isToday ? .bold : .regular)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isCompleted ? accentColor.opacity(0.3) : Color.clear)
            )
            .overlay(
                Circle()
                    .stroke(isToday ? accentColor : Color.clear, lineWidth: 2)
            )
            .overlay(
                isCompleted ? Image(systemName: "checkmark")
                    .font(.caption2)
                    .foregroundColor(accentColor) : nil
            )
    }
}

struct WeekChartView: View {
    let completedDates: [Date]
    let color: Color
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(last7Days, id: \.self) { date in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isDateCompleted(date) ? color : Color.gray.opacity(0.2))
                        .frame(height: isDateCompleted(date) ? 60 : 20)
                    
                    Text(dayName(date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 100)
    }
    
    var last7Days: [Date] {
        (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: Date())
        }.reversed()
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        completedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    func dayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date).prefix(2).uppercased()
    }
}
