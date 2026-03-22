import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    let icons: [String] = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "leaf.fill", "drop.fill", "sun.max.fill", "moon.fill",
        "cloud.fill", "snowflake", "wind", "sparkles",
        "figure.run", "figure.walk", "figure.hiking", "figure.yoga",
        "dumbbell.fill", "sportscourt.fill", "bicycle", "figure.pool.swim",
        "book.fill", "pencil", "doc.fill", "newspaper.fill",
        "graduationcap.fill", "brain.head.profile", "lightbulb.fill", "puzzlepiece.fill",
        "music.note", "guitars.fill", "pianokeys", "paintbrush.fill",
        "camera.fill", "film.fill", "tv.fill", "gamecontroller.fill",
        "cup.and.saucer.fill", "fork.knife", "carrot.fill", "leaf.arrow.triangle.circlepath",
        "pills.fill", "cross.fill", "bed.double.fill", "alarm.fill",
        "phone.fill", "envelope.fill", "message.fill", "bell.fill",
        "house.fill", "cart.fill", "bag.fill", "creditcard.fill",
        "dollarsign.circle.fill", "chart.pie.fill", "briefcase.fill", "person.fill",
        "person.2.fill", "pawprint.fill", "hare.fill", "tortoise.fill",
        "globe.americas.fill", "airplane", "car.fill", "tram.fill",
        "gift.fill", "party.popper.fill", "hands.clap.fill", "hand.thumbsup.fill",
        "face.smiling.fill", "swift", "terminal.fill", "hammer.fill"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? Color.blue : Color(.tertiarySystemGroupedBackground))
                                    .frame(height: 50)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ColorPicker: View {
    @Binding var selectedColor: HabitColor
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(HabitColor.allCases, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    ZStack {
                        Circle()
                            .fill(color.color)
                            .frame(width: 44, height: 44)
                        
                        if selectedColor == color {
                            Circle()
                                .strokeBorder(.white, lineWidth: 3)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack {
        ColorPicker(selectedColor: .constant(.blue))
            .padding()
    }
}
