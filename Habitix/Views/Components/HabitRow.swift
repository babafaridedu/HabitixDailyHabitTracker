import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let streak: Int
    let onToggle: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
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
                        .frame(width: 32, height: 32)
                    
                    Circle()
                        .strokeBorder(habit.color.color, lineWidth: 2)
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(isPressed ? 0.85 : 1.0)
            }
            .buttonStyle(.plain)
            
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(habit.color.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 18))
                        .foregroundColor(habit.color.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted, color: .secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("\(streak) day streak")
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
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .contentShape(Rectangle())
    }
}

struct CompactHabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
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
                    }
                }
            }
            .buttonStyle(.plain)
            
            Image(systemName: habit.icon)
                .font(.system(size: 14))
                .foregroundColor(habit.color.color)
                .frame(width: 24)
            
            Text(habit.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        HabitRow(
            habit: .preview,
            isCompleted: false,
            streak: 5,
            onToggle: {}
        )
        
        HabitRow(
            habit: Habit(title: "Read 30 minutes", icon: "book.fill", color: .blue),
            isCompleted: true,
            streak: 12,
            onToggle: {}
        )
        
        CompactHabitRow(
            habit: .preview,
            isCompleted: true,
            onToggle: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
