import SwiftUI

struct SettingsScreen: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        List {
            // Units Section
            Section(header: Text("units".localized)) {
                HStack {
                    Text("temperature".localized)
                    Spacer()
                    Picker("temperature".localized, selection: $settingsManager.temperatureUnit) {
                        Text("celsius".localized).tag(TemperatureUnit.celsius)
                        Text("fahrenheit".localized).tag(TemperatureUnit.fahrenheit)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("weight".localized)
                    Spacer()
                    Picker("weight".localized, selection: $settingsManager.weightUnit) {
                        Text("grams".localized).tag(WeightUnit.grams)
                        Text("ounces".localized).tag(WeightUnit.ounces)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // Language Section
            Section(header: Text("language".localized)) {
                HStack {
                    Text("language".localized)
                    Spacer()
                    Picker("language".localized, selection: $settingsManager.language) {
                        Text("english".localized).tag(Language.english)
                        Text("Español").tag(Language.spanish)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // Brewing Assistance Section
            Section(header: Text("brewing_assistance".localized)) {
                HStack {
                    Text("haptic_feedback".localized)
                    Spacer()
                    Toggle("", isOn: $settingsManager.hapticFeedback)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                }
                
                HStack {
                    Text("voice_cues".localized)
                    Spacer()
                    Toggle("", isOn: $settingsManager.voiceCues)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                }
            }
            
            // About Section
            Section(header: Text("about".localized)) {
                HStack {
                    Text("version".localized)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("build".localized)
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("settings".localized)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            localizationManager.currentLanguage = settingsManager.language
        }
        .onChange(of: settingsManager.language) { newLanguage in
            localizationManager.currentLanguage = newLanguage
        }
    }
}

#Preview {
    SettingsScreen()
} 