import Foundation

enum AgitationLevel: String, Codable, CaseIterable, Equatable {
    case low = "Low"       // Gentle pours, no stirring
    case medium = "Medium" // Standard pours, some spin
    case high = "High"     // Heavy turbulence, stirring
    
    var value: Double {
        switch self {
        case .low: return 0.2
        case .medium: return 0.5
        case .high: return 0.8
        }
    }
}

enum ThermalEnergy: String, Codable, CaseIterable, Equatable {
    case low = "Low"       // < 90C (Dark roasts, some Naturals)
    case medium = "Medium" // 90-94C (Medium roasts)
    case high = "High"     // > 94C (Light roasts, dense beans)
    
    var value: Double {
        switch self {
        case .low: return 0.2
        case .medium: return 0.5
        case .high: return 0.8
        }
    }
}

struct ExtractionCharacteristics: Codable, Equatable {
    // 0.0 (Body/Texture focus) -> 1.0 (Clarity/Separation focus)
    var clarity: Double
    
    // 0.0 (Low Acidity) -> 1.0 (High Acidity/Brightness)
    var acidity: Double
    
    // 0.0 (Low Sweetness) -> 1.0 (High Sweetness)
    var sweetness: Double
    
    // 0.0 (Tea-like) -> 1.0 (Heavy/Syrupy)
    var body: Double
    
    // Physical Brewing Parameters
    var agitation: AgitationLevel
    var thermal: ThermalEnergy
    
    // Default helpful init
    init(
        clarity: Double = 0.5,
        acidity: Double = 0.5,
        sweetness: Double = 0.5,
        body: Double = 0.5,
        agitation: AgitationLevel = .medium,
        thermal: ThermalEnergy = .medium
    ) {
        self.clarity = clarity
        self.acidity = acidity
        self.sweetness = sweetness
        self.body = body
        self.agitation = agitation
        self.thermal = thermal
    }
}

// MARK: - Knowledge Base Models

struct ExtractionBias: Codable {
    let clarity: Double
    let acidity: Double
    let sweetness: Double
    let body: Double
}

struct BrewingParameters: Codable {
    let agitationTolerance: AgitationLevel
    let thermalMassNeed: ThermalEnergy
    
    enum CodingKeys: String, CodingKey {
        case agitationTolerance = "agitation_tolerance"
        case thermalMassNeed = "thermal_mass_need"
    }
}

struct VarietyProfile: Codable, Identifiable {
    var id: String { variety }
    let variety: String
    let extractionBias: ExtractionBias
    let brewingParameters: BrewingParameters
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case variety
        case extractionBias = "extraction_bias"
        case brewingParameters = "brewing_parameters"
        case description
    }
}

struct ProcessProfile: Codable, Identifiable {
    var id: String { process }
    let process: String // "Washed", "Natural", etc.
    let extractionModifier: ExtractionBias // Additive/Multiplicative modifiers
    let brewingParameters: BrewingParameters // Overrides or Constraints
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case process
        case extractionModifier = "extraction_modifier"
        case brewingParameters = "brewing_parameters"
        case description
    }
}
