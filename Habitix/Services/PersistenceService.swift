import Foundation
import Combine

final class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    private let habitsKey = "habitix_habits"
    private let completionsKey = "habitix_completions"
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    @Published private(set) var habits: [Habit] = []
    @Published private(set) var completions: [HabitCompletion] = []
    
    private init() {
        loadHabits()
        loadCompletions()
    }
    
    // MARK: - Habits
    
    func loadHabits() {
        guard let data = defaults.data(forKey: habitsKey),
              let decoded = try? decoder.decode([Habit].self, from: data) else {
            habits = []
            return
        }
        habits = decoded.filter { !$0.isArchived }
    }
    
    func saveHabit(_ habit: Habit) {
        var allHabits = getAllHabitsIncludingArchived()
        if let index = allHabits.firstIndex(where: { $0.id == habit.id }) {
            allHabits[index] = habit
        } else {
            allHabits.append(habit)
        }
        saveHabits(allHabits)
    }
    
    func deleteHabit(_ habit: Habit) {
        var allHabits = getAllHabitsIncludingArchived()
        allHabits.removeAll { $0.id == habit.id }
        saveHabits(allHabits)
        
        var allCompletions = completions
        allCompletions.removeAll { $0.habitId == habit.id }
        saveCompletions(allCompletions)
    }
    
    private func getAllHabitsIncludingArchived() -> [Habit] {
        guard let data = defaults.data(forKey: habitsKey),
              let decoded = try? decoder.decode([Habit].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveHabits(_ habits: [Habit]) {
        if let encoded = try? encoder.encode(habits) {
            defaults.set(encoded, forKey: habitsKey)
        }
        loadHabits()
    }
    
    // MARK: - Completions
    
    func loadCompletions() {
        guard let data = defaults.data(forKey: completionsKey),
              let decoded = try? decoder.decode([HabitCompletion].self, from: data) else {
            completions = []
            return
        }
        completions = decoded
    }
    
    func toggleCompletion(for habit: Habit, on date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        if let index = completions.firstIndex(where: {
            $0.habitId == habit.id && Calendar.current.isDate($0.date, inSameDayAs: startOfDay)
        }) {
            var updated = completions
            updated.remove(at: index)
            saveCompletions(updated)
        } else {
            let completion = HabitCompletion(habitId: habit.id, date: startOfDay)
            var updated = completions
            updated.append(completion)
            saveCompletions(updated)
        }
    }
    
    func isCompleted(_ habit: Habit, on date: Date) -> Bool {
        completions.contains {
            $0.habitId == habit.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func completions(for habit: Habit) -> [HabitCompletion] {
        completions.filter { $0.habitId == habit.id }
    }
    
    func completions(on date: Date) -> [HabitCompletion] {
        completions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func saveCompletions(_ completions: [HabitCompletion]) {
        if let encoded = try? encoder.encode(completions) {
            defaults.set(encoded, forKey: completionsKey)
        }
        self.completions = completions
    }
    
    // MARK: - Reset
    
    func resetAllData() {
        defaults.removeObject(forKey: habitsKey)
        defaults.removeObject(forKey: completionsKey)
        habits = []
        completions = []
    }
    
    // MARK: - Statistics
    
    func currentStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let habitCompletions = completions(for: habit)
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        guard !habitCompletions.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        if !habitCompletions.contains(currentDate) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        while habitCompletions.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    func longestStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let sortedDates = completions(for: habit)
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDate),
               calendar.isDate(nextDay, inSameDayAs: currentDate) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if !calendar.isDate(previousDate, inSameDayAs: currentDate) {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    func completionRate(for habit: Habit, days: Int = 30) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            return 0
        }
        
        let habitCreatedDate = calendar.startOfDay(for: habit.createdAt)
        let effectiveStartDate = max(startDate, habitCreatedDate)
        
        let daysSinceStart = calendar.dateComponents([.day], from: effectiveStartDate, to: today).day ?? 0
        let totalDays = daysSinceStart + 1
        
        guard totalDays > 0 else { return 0 }
        
        let completedDays = completions(for: habit).filter { completion in
            completion.date >= effectiveStartDate && completion.date <= today
        }.count
        
        return Double(completedDays) / Double(totalDays)
    }
    
    func overallCompletionRate(days: Int = 30) -> Double {
        guard !habits.isEmpty else { return 0 }
        
        let rates = habits.map { completionRate(for: $0, days: days) }
        return rates.reduce(0, +) / Double(rates.count)
    }
    
    func weeklyCompletionData() -> [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        var result: [(day: String, count: Int)] = []
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let weekdayIndex = calendar.component(.weekday, from: date) - 1
            let completedCount = completions(on: date).count
            result.append((day: weekdays[weekdayIndex], count: completedCount))
        }
        
        return result
    }
}
