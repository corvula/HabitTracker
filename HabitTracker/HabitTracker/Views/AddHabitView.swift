import SwiftUI

struct AddHabitView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "007AFF"
    @State private var linkHealthKit = false
    @State private var selectedHealthKitType: HealthKitDataType?
    @State private var selectedPriority: HabitPriority = .medium
    @State private var notes = ""
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    
    let icons = ["star.fill", "heart.fill", "book.fill", "dumbbell.fill", "drop.fill", "moon.fill", "leaf.fill", "flame.fill"]
    let colors = ["007AFF", "34C759", "FF9500", "FF3B30", "AF52DE", "FF2D55", "5856D6", "00C7BE"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Назва") {
                    TextField("Наприклад: Читання", text: $name)
                }
                
                Section("Пріоритет") {
                    Picker("Пріоритет", selection: $selectedPriority) {
                        ForEach(HabitPriority.allCases, id: \.self) { priority in
                            Label(priority.rawValue, systemImage: priority.icon)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Іконка") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .blue : .gray)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Колір") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Нотатки") {
                    TextEditor(text: $notes)
                        .frame(height: 60)
                }
                
                Section {
                    Toggle("Підключити HealthKit", isOn: $linkHealthKit)
                    
                    if linkHealthKit {
                        Picker("Тип даних", selection: $selectedHealthKitType) {
                            Text("Оберіть тип").tag(nil as HealthKitDataType?)
                            ForEach(HealthKitDataType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon).tag(type as HealthKitDataType?)
                            }
                        }
                    }
                }
                
                Section {
                    Toggle("Увімкнути нагадування", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Час нагадування", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Нова звичка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Додати") {
                        let habit = Habit(
                            name: name,
                            icon: selectedIcon,
                            color: selectedColor,
                            isHealthKitLinked: linkHealthKit,
                            healthKitType: selectedHealthKitType,
                            priority: selectedPriority,
                            notes: notes,
                            reminderTime: reminderEnabled ? reminderTime : nil,
                            isReminderEnabled: reminderEnabled
                        )
                        viewModel.addHabit(habit)
                        if reminderEnabled {
                            NotificationManager.shared.scheduleNotification(for: habit, at: reminderTime)
                        }
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty || (linkHealthKit && selectedHealthKitType == nil))
                }
            }
        }
    }
}
