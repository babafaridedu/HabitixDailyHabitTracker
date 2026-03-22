import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddHabit = false
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    progressSection
                    
                    habitsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold))
            
            Text(todayFormatted)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                ProgressRing(
                    progress: viewModel.todayProgress,
                    lineWidth: 14,
                    size: 130,
                    foregroundColor: progressColor
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.completedTodayCount)/\(viewModel.todayHabits.count)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        
                        Text("Habits completed")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    
                    if viewModel.todayHabits.isEmpty {
                        Text("Add your first habit!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    } else if viewModel.todayProgress == 1 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("All done for today!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var progressColor: Color {
        switch viewModel.todayProgress {
        case 0..<0.33: return .red
        case 0.33..<0.66: return .orange
        case 0.66..<1: return .yellow
        default: return .green
        }
    }
    
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Habits")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                if !viewModel.todayHabits.isEmpty {
                    NavigationLink {
                        HabitsView()
                    } label: {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if viewModel.todayHabits.isEmpty {
                EmptyStateView(
                    icon: "list.bullet.clipboard",
                    title: "No Habits Yet",
                    message: "Start building better habits by adding your first one.",
                    buttonTitle: "Add Habit",
                    action: { showingAddHabit = true }
                )
                .frame(height: 300)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.todayHabits) { habit in
                        HabitRow(
                            habit: habit,
                            isCompleted: viewModel.isCompleted(habit),
                            streak: viewModel.currentStreak(for: habit),
                            onToggle: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.toggleCompletion(for: habit)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
