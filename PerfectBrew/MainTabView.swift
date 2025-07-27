import SwiftUI

struct MainTabView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TabView {
            NavigationView {
                HomeScreen()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Recipes")
            }
            
            NavigationView {
                BrewHistoryScreen()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Log")
            }
            
            NavigationView {
                SettingsScreen()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("settings".localized)
            }
        }
        .accentColor(.orange)
        .onAppear {
            localizationManager.currentLanguage = settingsManager.language
        }
        .onChange(of: settingsManager.language) { newLanguage in
            localizationManager.currentLanguage = newLanguage
        }
    }
}

#Preview {
    MainTabView()
} 