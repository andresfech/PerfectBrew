import Foundation

enum BodyPreference: String, CaseIterable, Codable {
    case light = "Light"
    case medium = "Medium"
    case full = "Full"
    
    /// Map body preference to target body value (0.0-1.0)
    var targetValue: Double {
        switch self {
        case .light: return 0.3
        case .medium: return 0.5
        case .full: return 0.7
        }
    }
}

enum BodyTexture: String, CaseIterable, Codable {
    case teaLike = "Tea-like"
    case creamySyrupy = "Creamy/Syrupy"
    
    /// Adjustments to clarity and body based on texture preference
    var clarityAdjustment: Double {
        switch self {
        case .teaLike: return 0.3
        case .creamySyrupy: return -0.2
        }
    }
    
    var bodyAdjustment: Double {
        switch self {
        case .teaLike: return -0.2
        case .creamySyrupy: return 0.3
        }
    }
}

enum AcidityPreference: String, CaseIterable, Codable {
    case brightJuicy = "Bright/Juicy"
    case smoothLow = "Smooth/Low"
    
    /// Adjustment to target acidity based on preference
    var acidityAdjustment: Double {
        switch self {
        case .brightJuicy: return 0.25
        case .smoothLow: return -0.25
        }
    }
}

enum SweetnessPreference: String, CaseIterable, Codable {
    case sweet = "Sweet"
    case balanced = "Balanced"
    case bitter = "Bitter"
    
    /// Adjustment to target sweetness based on preference
    var sweetnessAdjustment: Double {
        switch self {
        case .sweet: return 0.3
        case .balanced: return 0.0
        case .bitter: return -0.2
        }
    }
}

enum RecommendationType: String, CaseIterable, Codable {
    case general = "General"
    case methodSpecific = "Method-specific"
}

struct UserTastePreferences: Codable {
    var bodyPreference: BodyPreference
    var bodyTexture: BodyTexture?
    var acidityPreference: AcidityPreference
    var sweetnessPreference: SweetnessPreference
    var recommendationType: RecommendationType
    var selectedMethod: String? // Brewing method if methodSpecific
    
    /// Adjust a target ExtractionCharacteristics profile based on user preferences
    /// Uses weighted blend: 70% coffee characteristics, 30% preferences
    func adjustTargetProfile(_ baseProfile: ExtractionCharacteristics) -> ExtractionCharacteristics {
        var adjusted = baseProfile
        
        // Body preference adjustment (70/30 blend)
        let preferredBody = bodyPreference.targetValue
        adjusted.body = baseProfile.body * 0.7 + preferredBody * 0.3
        
        // Body texture adjustment (if specified)
        if let texture = bodyTexture {
            adjusted.clarity = max(0.0, min(1.0, adjusted.clarity + texture.clarityAdjustment))
            adjusted.body = max(0.0, min(1.0, adjusted.body + texture.bodyAdjustment))
        }
        
        // Acidity preference adjustment (70/30 blend)
        let preferredAcidity = max(0.0, min(1.0, baseProfile.acidity + acidityPreference.acidityAdjustment))
        adjusted.acidity = baseProfile.acidity * 0.7 + preferredAcidity * 0.3
        
        // Sweetness preference adjustment (70/30 blend)
        let preferredSweetness = max(0.0, min(1.0, baseProfile.sweetness + sweetnessPreference.sweetnessAdjustment))
        adjusted.sweetness = baseProfile.sweetness * 0.7 + preferredSweetness * 0.3
        
        // Clamp all values to valid range
        adjusted.clarity = max(0.0, min(1.0, adjusted.clarity))
        adjusted.acidity = max(0.0, min(1.0, adjusted.acidity))
        adjusted.sweetness = max(0.0, min(1.0, adjusted.sweetness))
        adjusted.body = max(0.0, min(1.0, adjusted.body))
        
        // Keep physical constraints from coffee profile (agitation, thermal)
        // These should not be adjusted by preferences
        
        return adjusted
    }
    
    /// Calculate preference alignment score (0-100) for a recipe's extraction characteristics
    func calculatePreferenceAlignmentScore(recipe: ExtractionCharacteristics) -> Int {
        var score = 0.0
        let maxScore = 100.0
        
        // Body alignment (25 points)
        let bodyDiff = abs(recipe.body - bodyPreference.targetValue)
        score += (1.0 - bodyDiff) * 25.0
        
        // Acidity alignment (25 points)
        let preferredAcidity = 0.5 + acidityPreference.acidityAdjustment
        let acidityDiff = abs(recipe.acidity - preferredAcidity)
        score += (1.0 - acidityDiff) * 25.0
        
        // Sweetness alignment (25 points)
        let preferredSweetness = 0.5 + sweetnessPreference.sweetnessAdjustment
        let sweetnessDiff = abs(recipe.sweetness - preferredSweetness)
        score += (1.0 - sweetnessDiff) * 25.0
        
        // Body texture alignment (25 points, if specified)
        if let texture = bodyTexture {
            let preferredClarity: Double = texture == .teaLike ? 0.8 : 0.4
            let clarityDiff = abs(recipe.clarity - preferredClarity)
            score += (1.0 - clarityDiff) * 25.0
        } else {
            // If texture not specified, give neutral score
            score += 12.5
        }
        
        return Int(max(0, min(100, score)))
    }
}

