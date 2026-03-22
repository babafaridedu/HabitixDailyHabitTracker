import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var icon: String
    var color: HabitColor
    var frequency: HabitFrequency
    var createdAt: Date
    var isArchived: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        icon: String = "star.fill",
        color: HabitColor = .blue,
        frequency: HabitFrequency = .daily,
        createdAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}

enum HabitColor: String, Codable, CaseIterable {
    case red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown
    
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .mint: return .mint
        case .teal: return .teal
        case .cyan: return .cyan
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        }
    }
    
    var name: String {
        rawValue.capitalized
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct HabitCompletion: Identifiable, Codable, Equatable {
    let id: UUID
    let habitId: UUID
    let date: Date
    let completedAt: Date
    
    init(id: UUID = UUID(), habitId: UUID, date: Date, completedAt: Date = Date()) {
        self.id = id
        self.habitId = habitId
        self.date = Calendar.current.startOfDay(for: date)
        self.completedAt = completedAt
    }
}

extension Habit {
    static let preview = Habit(
        title: "Morning Exercise",
        icon: "figure.run",
        color: .green
    )
    
    static let previews: [Habit] = [
        Habit(title: "Morning Exercise", icon: "figure.run", color: .green),
        Habit(title: "Read 30 minutes", icon: "book.fill", color: .blue),
        Habit(title: "Drink Water", icon: "drop.fill", color: .cyan),
        Habit(title: "Meditate", icon: "brain.head.profile", color: .purple),
        Habit(title: "Learn Swift", icon: "swift", color: .orange)
    ]
}
