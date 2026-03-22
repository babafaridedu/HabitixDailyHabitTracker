import Foundation
import SwiftUI
import Combine

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completions: [HabitCompletion] = []
    @Published var selectedDate: Date = Date()
    @Published var searchText: String = ""
    
    private let persistence: PersistenceService
    private var cancellables = Set<AnyCancellable>()
    
    var todayHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }
    
    var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return todayHabits
        }
        return todayHabits.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var completedTodayCount: Int {
        todayHabits.filter { isCompleted($0, on: Date()) }.count
    }
    
    var todayProgress: Double {
        guard !todayHabits.isEmpty else { return 0 }
        return Double(completedTodayCount) / Double(todayHabits.count)
    }
    
    init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        setupBindings()
    }
    
    private func setupBindings() {
        persistence.$habits
            .receive(on: DispatchQueue.main)
            .assign(to: &$habits)
        
        persistence.$completions
            .receive(on: DispatchQueue.main)
            .assign(to: &$completions)
    }
    
    func refresh() {
        persistence.loadHabits()
        persistence.loadCompletions()
    }
    
    func addHabit(_ habit: Habit) {
        persistence.saveHabit(habit)
    }
    
    func updateHabit(_ habit: Habit) {
        persistence.saveHabit(habit)
    }
    
    func deleteHabit(_ habit: Habit) {
        persistence.deleteHabit(habit)
    }
    
    func toggleCompletion(for habit: Habit, on date: Date = Date()) {
        persistence.toggleCompletion(for: habit, on: date)
    }
    
    func isCompleted(_ habit: Habit, on date: Date = Date()) -> Bool {
        persistence.isCompleted(habit, on: date)
    }
    
    func currentStreak(for habit: Habit) -> Int {
        persistence.currentStreak(for: habit)
    }
    
    func completionRate(for habit: Habit) -> Double {
        persistence.completionRate(for: habit)
    }
}
