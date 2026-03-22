import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 120
    var backgroundColor: Color = .gray.opacity(0.2)
    var foregroundColor: Color = .blue
    var showPercentage: Bool = true
    
    private var normalizedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: normalizedProgress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: normalizedProgress)
            
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(normalizedProgress * 100))%")
                        .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    
                    Text("Complete")
                        .font(.system(size: size * 0.1, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct MiniProgressRing: View {
    let progress: Double
    var size: CGFloat = 24
    var lineWidth: CGFloat = 3
    var foregroundColor: Color = .blue
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        ProgressRing(progress: 0.75, foregroundColor: .green)
        ProgressRing(progress: 0.5, size: 80, foregroundColor: .orange)
        
        HStack(spacing: 20) {
            MiniProgressRing(progress: 0.3, foregroundColor: .red)
            MiniProgressRing(progress: 0.6, foregroundColor: .blue)
            MiniProgressRing(progress: 1.0, foregroundColor: .green)
        }
    }
    .padding()
}
