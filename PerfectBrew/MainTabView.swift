import SwiftUI

struct MainTabView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0  // Start with Home tab
    @State private var shouldNavigateToHome = false
    @State private var isInitialLoad = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeScreen()
            }
                          .tabItem {
                  Image(systemName: "house.fill")
                  Text("Home")
              }
            .tag(0)
            
            NavigationStack {
                BrewHistoryScreen()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Log")
            }
            .tag(1)
            
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("settings".localized)
            }
            .tag(2)
        }
        .accentColor(.orange)
        .onAppear {
            localizationManager.currentLanguage = settingsManager.language
            // Reset selection to show no tab as selected initially
            if isInitialLoad {
                selectedTab = -1
                isInitialLoad = false
            }
        }
        .onChange(of: settingsManager.language) { newLanguage in
            localizationManager.currentLanguage = newLanguage
        }
        .onChange(of: selectedTab) { newTab in
            // Si se selecciona el tab Home (0), forzar la navegación al inicio
            if newTab == 0 {
                shouldNavigateToHome = true
                // Forzar la navegación al home
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    shouldNavigateToHome = false
                }
            }
        }
    }
}

#Preview {
    MainTabView()
} 