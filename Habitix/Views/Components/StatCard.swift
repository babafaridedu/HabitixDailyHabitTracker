import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = .blue
    var trend: Trend? = nil
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(trend.color)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

struct LargeStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    var iconColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            StatCard(
                title: "Current Streak",
                value: "12",
                icon: "flame.fill",
                iconColor: .orange,
                trend: .up
            )
            
            StatCard(
                title: "Completion Rate",
                value: "85%",
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .green
            )
        }
        
        LargeStatCard(
            title: "Best Streak",
            value: "30",
            subtitle: "days in a row",
            icon: "trophy.fill",
            iconColor: .yellow
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
