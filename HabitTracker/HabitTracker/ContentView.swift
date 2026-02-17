import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddHabit = false
    @State private var currentQuote = MotivationalQuote.random()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        motivationalQuoteCard
                        
                        if viewModel.habits.isEmpty {
                            emptyStateView
                        } else {
                            // Сортування за пріоритетом
                            ForEach(sortedHabits) { habit in
                                HabitCard(habit: habit, viewModel: viewModel)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Звички")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.syncHealthKitData()
                        currentQuote = MotivationalQuote.random()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    var sortedHabits: [Habit] {
        viewModel.habits.sorted { habit1, habit2 in
            let priorityOrder: [HabitPriority] = [.high, .medium, .low]
            let index1 = priorityOrder.firstIndex(of: habit1.priority) ?? 0
            let index2 = priorityOrder.firstIndex(of: habit2.priority) ?? 0
            return index1 < index2
        }
    }
    
    var motivationalQuoteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.blue)
                Text("Мотивація дня")
                    .font(.headline)
                Spacer()
                Button(action: {
                    currentQuote = MotivationalQuote.random()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Text(currentQuote.text)
                .font(.body)
                .foregroundColor(.primary)
            
            if !currentQuote.author.isEmpty {
                Text("— \(currentQuote.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Немає звичок")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Додайте свою першу звичку")
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }
}
