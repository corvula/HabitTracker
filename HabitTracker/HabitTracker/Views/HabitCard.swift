import SwiftUI

struct HabitCard: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            HabitDetailView(habit: habit)
        }
    }
    
    var cardContent: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: habit.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if habit.isHealthKitLinked {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Image(systemName: habit.priority.icon)
                        .font(.caption)
                        .foregroundColor(Color(hex: habit.priority.color))
                }
                
                HStack(spacing: 12) {
                    Label("\(habit.currentStreak)", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Label("\(habit.completedDates.count)", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Label("\(habit.bestStreak)", systemImage: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            Button(action: { viewModel.toggleHabit(habit) }) {
                Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(habit.isCompletedToday() ? Color(hex: habit.color) : .gray.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteHabit(habit)
            } label: {
                Label("Видалити", systemImage: "trash")
            }
        }
    }
}
