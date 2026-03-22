import SwiftUI

@main
struct HabitixApp: App {
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
    
    private var selectedTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(selectedTheme.colorScheme)
        }
    }
}
