import Foundation
import SwiftUI

enum TemperatureUnit: String, CaseIterable, Codable {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

enum WeightUnit: String, CaseIterable, Codable {
    case grams = "grams"
    case ounces = "ounces"
    
    var symbol: String {
        switch self {
        case .grams: return "g"
        case .ounces: return "oz"
        }
    }
}

enum Language: String, CaseIterable, Codable {
    case english = "en"
    case spanish = "es"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(temperatureUnit.rawValue, forKey: "temperatureUnit")
        }
    }
    
    @Published var weightUnit: WeightUnit {
        didSet {
            UserDefaults.standard.set(weightUnit.rawValue, forKey: "weightUnit")
        }
    }
    
    @Published var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "language")
            LocalizationManager.shared.updateLanguage(language)
        }
    }
    
    @Published var hapticFeedback: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedback, forKey: "hapticFeedback")
        }
    }
    
    @Published var voiceCues: Bool {
        didSet {
            UserDefaults.standard.set(voiceCues, forKey: "voiceCues")
        }
    }
    
    private init() {
        // Load saved settings or use defaults
        let savedTempUnit = UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: savedTempUnit) ?? .celsius
        
        let savedWeightUnit = UserDefaults.standard.string(forKey: "weightUnit") ?? WeightUnit.grams.rawValue
        self.weightUnit = WeightUnit(rawValue: savedWeightUnit) ?? .grams
        
        let savedLanguage = UserDefaults.standard.string(forKey: "language") ?? Language.english.rawValue
        self.language = Language(rawValue: savedLanguage) ?? .english
        
        self.hapticFeedback = UserDefaults.standard.bool(forKey: "hapticFeedback")
        self.voiceCues = UserDefaults.standard.bool(forKey: "voiceCues")
    }
    
    // Unit conversion methods
    func convertTemperature(_ celsius: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return (celsius * 9/5) + 32
        }
    }
    
    func convertWeight(_ grams: Double) -> Double {
        switch weightUnit {
        case .grams:
            return grams
        case .ounces:
            return grams / 28.35
        }
    }
    
    func formatTemperature(_ celsius: Double) -> String {
        let converted = convertTemperature(celsius)
        return String(format: "%.0f%@", converted, temperatureUnit.symbol)
    }
    
    func formatWeight(_ grams: Double) -> String {
        let converted = convertWeight(grams)
        return String(format: "%.1f%@", converted, weightUnit.symbol)
    }
} 