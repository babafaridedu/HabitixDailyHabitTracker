import Foundation
import SwiftUI
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var weeklyData: [(day: String, count: Int)] = []
    
    private let persistence: PersistenceService
    
    var totalHabits: Int {
        habits.count
    }
    
    var overallCompletionRate: Double {
        persistence.overallCompletionRate()
    }
    
    var bestStreak: Int {
        habits.map { persistence.longestStreak(for: $0) }.max() ?? 0
    }
    
    var totalCompletions: Int {
        persistence.completions.count
    }
    
    var habitStats: [HabitStatistic] {
        habits.map { habit in
            HabitStatistic(
                habit: habit,
                currentStreak: persistence.currentStreak(for: habit),
                longestStreak: persistence.longestStreak(for: habit),
                completionRate: persistence.completionRate(for: habit),
                totalCompletions: persistence.completions(for: habit).count
            )
        }
        .sorted { $0.currentStreak > $1.currentStreak }
    }
    
    init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        refresh()
    }
    
    func refresh() {
        habits = persistence.habits
        weeklyData = persistence.weeklyCompletionData()
    }
}

struct HabitStatistic: Identifiable {
    let id = UUID()
    let habit: Habit
    let currentStreak: Int
    let longestStreak: Int
    let completionRate: Double
    let totalCompletions: Int
}
