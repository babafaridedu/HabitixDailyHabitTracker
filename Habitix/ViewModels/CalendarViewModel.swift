import Foundation
import SwiftUI
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var habits: [Habit] = []
    @Published var completions: [HabitCompletion] = []
    
    private let persistence: PersistenceService
    private let calendar = Calendar.current
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        let firstDayOfMonth = monthInterval.start
        while currentDate < firstDayOfMonth {
            days.append(nil)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    var selectedDateHabits: [(habit: Habit, isCompleted: Bool)] {
        habits.map { habit in
            (habit: habit, isCompleted: persistence.isCompleted(habit, on: selectedDate))
        }
    }
    
    var selectedDateCompletionCount: Int {
        selectedDateHabits.filter { $0.isCompleted }.count
    }
    
    init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        setupBindings()
    }
    
    private func setupBindings() {
        habits = persistence.habits
        completions = persistence.completions
    }
    
    func refresh() {
        habits = persistence.habits
        completions = persistence.completions
    }
    
    func completionCount(for date: Date) -> Int {
        persistence.completions(on: date).count
    }
    
    func hasCompletions(on date: Date) -> Bool {
        completionCount(for: date) > 0
    }
    
    func completionProgress(for date: Date) -> Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completionCount(for: date)) / Double(habits.count)
    }
    
    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func dayNumber(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    func toggleCompletion(for habit: Habit) {
        persistence.toggleCompletion(for: habit, on: selectedDate)
        refresh()
    }
    
    func isCompleted(_ habit: Habit) -> Bool {
        persistence.isCompleted(habit, on: selectedDate)
    }
}
