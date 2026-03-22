import SwiftUI

struct AddHabitView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var icon = "star.fill"
    @State private var color: HabitColor = .blue
    @State private var frequency: HabitFrequency = .daily
    @State private var showIconPicker = false
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit name", text: $title)
                        .font(.system(size: 16))
                } header: {
                    Text("Title")
                }
                
                Section {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color.color.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(color.color)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    ColorPicker(selectedColor: $color)
                        .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
                
                Section {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Frequency")
                }
                
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(color.color.opacity(0.15))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: icon)
                                .font(.system(size: 28))
                                .foregroundColor(color.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title.isEmpty ? "Habit Name" : title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(title.isEmpty ? .secondary : .primary)
                            
                            Text(frequency.rawValue)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let habit = Habit(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            icon: icon,
                            color: color,
                            frequency: frequency
                        )
                        viewModel.addHabit(habit)
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPicker(selectedIcon: $icon)
            }
        }
    }
}

struct EditHabitView: View {
    @ObservedObject var viewModel: HabitViewModel
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var icon: String
    @State private var color: HabitColor
    @State private var frequency: HabitFrequency
    @State private var showIconPicker = false
    
    init(viewModel: HabitViewModel, habit: Habit) {
        self.viewModel = viewModel
        self.habit = habit
        _title = State(initialValue: habit.title)
        _icon = State(initialValue: habit.icon)
        _color = State(initialValue: habit.color)
        _frequency = State(initialValue: habit.frequency)
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit name", text: $title)
                        .font(.system(size: 16))
                } header: {
                    Text("Title")
                }
                
                Section {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(color.color.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(color.color)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    ColorPicker(selectedColor: $color)
                        .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
                
                Section {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Frequency")
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = habit
                        updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.icon = icon
                        updated.color = color
                        updated.frequency = frequency
                        viewModel.updateHabit(updated)
                        dismiss()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPicker(selectedIcon: $icon)
            }
        }
    }
}

#Preview {
    AddHabitView(viewModel: HabitViewModel())
}
