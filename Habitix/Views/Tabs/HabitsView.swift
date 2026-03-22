import SwiftUI

struct HabitsView: View {
    @StateObject private var viewModel = HabitViewModel()
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit?
    @State private var habitToDelete: Habit?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habits.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No Habits",
                        message: "Create habits to start tracking your daily progress.",
                        buttonTitle: "Create Habit",
                        action: { showingAddHabit = true }
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredHabits) { habit in
                            HabitListRow(
                                habit: habit,
                                streak: viewModel.currentStreak(for: habit),
                                completionRate: viewModel.completionRate(for: habit)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                habitToEdit = habit
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    habitToDelete = habit
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    habitToEdit = habit
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $viewModel.searchText, prompt: "Search habits")
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habits")
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
            .sheet(item: $habitToEdit) { habit in
                EditHabitView(viewModel: viewModel, habit: habit)
            }
            .alert("Delete Habit", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let habit = habitToDelete {
                        withAnimation {
                            viewModel.deleteHabit(habit)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this habit? All completion history will be lost.")
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }
}

struct HabitListRow: View {
    let habit: Habit
    let streak: Int
    let completionRate: Double
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(habit.color.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 20))
                    .foregroundColor(habit.color.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        Text("\(streak) days")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("\(Int(completionRate * 100))%")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HabitsView()
}
