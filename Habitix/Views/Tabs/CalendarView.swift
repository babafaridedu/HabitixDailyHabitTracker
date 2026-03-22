import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    calendarSection
                    
                    selectedDateSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calendar")
            .onAppear {
                viewModel.refresh()
            }
        }
    }
    
    private var calendarSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.previousMonth()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
                
                Text(viewModel.monthTitle)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.nextMonth()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(viewModel.daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isToday: viewModel.isToday(date),
                            isSelected: viewModel.isSelected(date),
                            progress: viewModel.completionProgress(for: date),
                            dayNumber: viewModel.dayNumber(for: date)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(formattedSelectedDate)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Text("\(viewModel.selectedDateCompletionCount)/\(viewModel.habits.count) completed")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            
            if viewModel.selectedDateHabits.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    
                    Text("No habits for this date")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.selectedDateHabits, id: \.habit.id) { item in
                        CalendarHabitRow(
                            habit: item.habit,
                            isCompleted: item.isCompleted,
                            onToggle: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.toggleCompletion(for: item.habit)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: viewModel.selectedDate)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let progress: Double
    let dayNumber: String
    
    private var progressColor: Color {
        switch progress {
        case 0: return .clear
        case 0..<0.5: return .orange
        case 0.5..<1: return .yellow
        default: return .green
        }
    }
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
            } else if isToday {
                Circle()
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .frame(width: 40, height: 40)
            }
            
            if progress > 0 && !isSelected {
                Circle()
                    .fill(progressColor.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            
            Text(dayNumber)
                .font(.system(size: 14, weight: isToday || isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(height: 44)
    }
}

struct CalendarHabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                    onToggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? habit.color.color : Color.clear)
                        .frame(width: 28, height: 28)
                    
                    Circle()
                        .strokeBorder(habit.color.color, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(isPressed ? 0.85 : 1.0)
            }
            .buttonStyle(.plain)
            
            Image(systemName: habit.icon)
                .font(.system(size: 14))
                .foregroundColor(habit.color.color)
                .frame(width: 20)
            
            Text(habit.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .strikethrough(isCompleted, color: .secondary)
            
            Spacer()
            
            Text(isCompleted ? "Done" : "Tap to complete")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    CalendarView()
}
