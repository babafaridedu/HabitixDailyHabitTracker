import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    overviewSection
                    
                    weeklyChartSection
                    
                    habitsStatsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statistics")
            .onAppear {
                viewModel.refresh()
            }
        }
    }
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Habits",
                    value: "\(viewModel.totalHabits)",
                    icon: "checkmark.circle.fill",
                    iconColor: .blue
                )
                
                StatCard(
                    title: "Completion Rate",
                    value: "\(Int(viewModel.overallCompletionRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Best Streak",
                    value: "\(viewModel.bestStreak)",
                    icon: "flame.fill",
                    iconColor: .orange
                )
                
                StatCard(
                    title: "Total Completions",
                    value: "\(viewModel.totalCompletions)",
                    icon: "star.fill",
                    iconColor: .yellow
                )
            }
        }
    }
    
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 7 Days")
                .font(.system(size: 18, weight: .bold))
            
            if viewModel.weeklyData.isEmpty || viewModel.weeklyData.allSatisfy({ $0.count == 0 }) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    
                    Text("No data yet")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart(viewModel.weeklyData, id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Completions", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let intValue = value.as(Int.self) {
                            AxisValueLabel {
                                Text("\(intValue)")
                                    .font(.system(size: 10))
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .font(.system(size: 10, weight: .medium))
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var habitsStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Details")
                .font(.system(size: 18, weight: .bold))
            
            if viewModel.habitStats.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    
                    Text("Add habits to see stats")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.habitStats) { stat in
                        HabitStatRow(stat: stat)
                    }
                }
            }
        }
    }
}

struct HabitStatRow: View {
    let stat: HabitStatistic
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(stat.habit.color.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: stat.habit.icon)
                        .font(.system(size: 16))
                        .foregroundColor(stat.habit.color.color)
                }
                
                Text(stat.habit.title)
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                MiniProgressRing(
                    progress: stat.completionRate,
                    size: 32,
                    lineWidth: 4,
                    foregroundColor: stat.habit.color.color
                )
            }
            
            HStack(spacing: 0) {
                StatItem(title: "Current", value: "\(stat.currentStreak)", icon: "flame.fill", color: .orange)
                
                Divider()
                    .frame(height: 30)
                
                StatItem(title: "Best", value: "\(stat.longestStreak)", icon: "trophy.fill", color: .yellow)
                
                Divider()
                    .frame(height: 30)
                
                StatItem(title: "Rate", value: "\(Int(stat.completionRate * 100))%", icon: "chart.bar.fill", color: .green)
                
                Divider()
                    .frame(height: 30)
                
                StatItem(title: "Total", value: "\(stat.totalCompletions)", icon: "checkmark.circle.fill", color: .blue)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatisticsView()
}
