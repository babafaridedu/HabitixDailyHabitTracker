import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    
    private var selectedTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }
    
    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                
                dataSection
            }
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    PersistenceService.shared.resetAllData()
                    showResetSuccess = true
                }
            } message: {
                Text("This will permanently delete all your habits and completion history. This action cannot be undone.")
            }
            .alert("Data Reset", isPresented: $showResetSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("All data has been successfully reset.")
            }
        }
    }
    
    private var appearanceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeButton(
                            theme: theme,
                            isSelected: selectedTheme == theme,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appTheme = theme.rawValue
                                }
                            }
                        )
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Label("Appearance", systemImage: "paintbrush.fill")
        }
    }
    
    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                    
                    Text("Reset All Data")
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
        } header: {
            Label("Data", systemImage: "externaldrive.fill")
        } footer: {
            Text("This will delete all habits and completion history.")
        }
    }
}

struct ThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color(.tertiarySystemGroupedBackground))
                        .frame(height: 50)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(theme.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingsView()
}
