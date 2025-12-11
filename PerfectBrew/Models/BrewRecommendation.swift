import Foundation

// MARK: - Recommendation Models (AEC-12)

// MARK: - Unified Direction System (AEC-12 v2)

/// The single direction ALL adjustments should follow - no contradictions
enum ExtractionDirection: String, Codable {
    case increase = "Increase Extraction"   // Under-extracted → finer, hotter, longer
    case decrease = "Decrease Extraction"   // Over-extracted → coarser, cooler, shorter
    case adjustStrength = "Adjust Strength" // Dose/ratio changes only (not extraction)
    case improveTechnique = "Improve Technique" // Channeling/evenness issues
    case balanced = "Maintain Balance"      // Minor tweaks only
    
    var icon: String {
        switch self {
        case .increase: return "arrow.up.circle.fill"
        case .decrease: return "arrow.down.circle.fill"
        case .adjustStrength: return "scalemass.fill"
        case .improveTechnique: return "hand.draw.fill"
        case .balanced: return "checkmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .increase: return "orange"
        case .decrease: return "blue"
        case .adjustStrength: return "green"
        case .improveTechnique: return "purple"
        case .balanced: return "green"
        }
    }
    
    var actionVerb: String {
        switch self {
        case .increase: return "extracting more"
        case .decrease: return "extracting less"
        case .adjustStrength: return "adjusting strength"
        case .improveTechnique: return "improving evenness"
        case .balanced: return "fine-tuning"
        }
    }
}

/// A single adjustment item within the unified recommendation
struct AdjustmentItem: Identifiable, Codable {
    let id: UUID
    let rank: Int                    // 1 = highest impact for this method
    let category: RecommendationCategory
    let parameter: String            // "Grind Size", "Water Temperature"
    let currentValue: String?        // "18 clicks", "96°C" (if known)
    let suggestedChange: String      // "2 clicks finer", "Lower to 92°C"
    let impactPercent: Int           // 85 = 85% impact weight
    let explanation: String          // Why this helps
    
    init(
        id: UUID = UUID(),
        rank: Int,
        category: RecommendationCategory,
        parameter: String,
        currentValue: String? = nil,
        suggestedChange: String,
        impactPercent: Int,
        explanation: String
    ) {
        self.id = id
        self.rank = rank
        self.category = category
        self.parameter = parameter
        self.currentValue = currentValue
        self.suggestedChange = suggestedChange
        self.impactPercent = impactPercent
        self.explanation = explanation
    }
}

/// Unified brew adjustment - ALL items align to ONE direction
struct UnifiedBrewAdjustment: Codable {
    let direction: ExtractionDirection
    let confidence: Double           // 0.0 - 1.0
    let summary: String              // "Your brew needs more extraction"
    let adjustments: [AdjustmentItem] // Ranked by impact, all aligned
    
    /// Primary adjustment (highest impact)
    var primaryAdjustment: AdjustmentItem? {
        adjustments.first
    }
    
    /// Secondary adjustments (supporting changes)
    var secondaryAdjustments: [AdjustmentItem] {
        Array(adjustments.dropFirst())
    }
}

// MARK: - Method-Specific Impact Rankings

/// Defines which adjustments have most impact per brewing method
struct MethodImpactRankings {
    /// Rankings: 1 = highest impact, 4 = lowest impact
    static let rankings: [String: [RecommendationCategory: Int]] = [
        "V60": [
            .grind: 1,
            .technique: 2,
            .temperature: 3,
            .time: 4,
            .ratio: 5,
            .dose: 6
        ],
        "Chemex": [
            .grind: 1,
            .technique: 2,
            .temperature: 3,
            .time: 4,
            .ratio: 5,
            .dose: 6
        ],
        "AeroPress": [
            .grind: 1,
            .time: 2,
            .temperature: 3,
            .technique: 4,
            .ratio: 5,
            .dose: 6
        ],
        "French Press": [
            .time: 1,
            .grind: 2,
            .temperature: 3,
            .technique: 4,
            .ratio: 5,
            .dose: 6
        ],
        "Espresso": [
            .grind: 1,
            .dose: 2,
            .time: 3,
            .temperature: 4,
            .technique: 5,
            .ratio: 6
        ]
    ]
    
    /// Get impact rank for a category and method (lower = more impact)
    static func getRank(for category: RecommendationCategory, method: String) -> Int {
        // Try exact match first
        if let methodRankings = rankings[method] {
            return methodRankings[category] ?? 99
        }
        
        // Try partial match (e.g., "V60 Kasuya" → "V60")
        for (key, methodRankings) in rankings {
            if method.contains(key) {
                return methodRankings[category] ?? 99
            }
        }
        
        // Default rankings
        let defaultRankings: [RecommendationCategory: Int] = [
            .grind: 1,
            .time: 2,
            .temperature: 3,
            .technique: 4,
            .ratio: 5,
            .dose: 6
        ]
        return defaultRankings[category] ?? 99
    }
    
    /// Convert rank to impact percentage (rank 1 = 90%, rank 6 = 40%)
    static func rankToImpactPercent(_ rank: Int) -> Int {
        switch rank {
        case 1: return 90
        case 2: return 75
        case 3: return 60
        case 4: return 50
        case 5: return 40
        case 6: return 35
        default: return 30
        }
    }
}

/// A single actionable recommendation for improving a brew
struct BrewRecommendation: Identifiable, Codable {
    let id: UUID
    let priority: Int              // 1 = highest priority
    let category: RecommendationCategory
    let action: String             // "Grind Finer"
    let reason: String             // "Your acidity was lower than expected"
    let expectedVsActual: String?  // "Expected: High → Got: Low"
    let impact: String             // "This will increase extraction..."
    
    init(
        id: UUID = UUID(),
        priority: Int,
        category: RecommendationCategory,
        action: String,
        reason: String,
        expectedVsActual: String? = nil,
        impact: String
    ) {
        self.id = id
        self.priority = priority
        self.category = category
        self.action = action
        self.reason = reason
        self.expectedVsActual = expectedVsActual
        self.impact = impact
    }
}

/// Categories of brewing adjustments
enum RecommendationCategory: String, Codable, CaseIterable {
    case grind = "Grind"
    case temperature = "Temperature"
    case time = "Time"
    case ratio = "Ratio"
    case technique = "Technique"
    case dose = "Dose"
    
    var icon: String {
        switch self {
        case .grind: return "gearshape.2"
        case .temperature: return "thermometer"
        case .time: return "clock"
        case .ratio: return "scalemass"
        case .technique: return "hand.draw"
        case .dose: return "cup.and.saucer"
        }
    }
    
    var color: String {
        switch self {
        case .grind: return "orange"
        case .temperature: return "red"
        case .time: return "blue"
        case .ratio: return "green"
        case .technique: return "purple"
        case .dose: return "brown"
        }
    }
}

/// Overall extraction assessment
enum ExtractionAssessment: String, Codable {
    case underExtracted = "Under-extracted"
    case overExtracted = "Over-extracted"
    case balanced = "Balanced"
    case lowStrength = "Low Strength"
    case highStrength = "High Strength"
    case channeling = "Channeling"
    
    var description: String {
        switch self {
        case .underExtracted:
            return "Not enough flavor compounds were dissolved from the coffee."
        case .overExtracted:
            return "Too many compounds were dissolved, including harsh ones."
        case .balanced:
            return "Your extraction was well-balanced. Minor tweaks might enhance specific notes."
        case .lowStrength:
            return "The brew is thin. Consider adjusting your coffee-to-water ratio."
        case .highStrength:
            return "The brew is intense. You might want to dilute or adjust ratio."
        case .channeling:
            return "Water flowed unevenly through the coffee bed."
        }
    }
    
    var icon: String {
        switch self {
        case .underExtracted: return "arrow.down.circle"
        case .overExtracted: return "arrow.up.circle"
        case .balanced: return "checkmark.circle"
        case .lowStrength: return "drop"
        case .highStrength: return "drop.fill"
        case .channeling: return "arrow.triangle.branch"
        }
    }
}

/// Actual taste profile derived from user feedback
struct ActualTasteProfile: Codable {
    let acidity: Double      // 0.0 - 1.0 (converted from 0-5 slider)
    let sweetness: Double    // 0.0 - 1.0
    let bitterness: Double   // 0.0 - 1.0
    let body: Double         // 0.0 - 1.0
    
    /// Convert from FeedbackData slider values (0-5) to normalized (0-1)
    static func from(feedback: FeedbackData) -> ActualTasteProfile {
        return ActualTasteProfile(
            acidity: feedback.acidityLevel / 5.0,
            sweetness: feedback.sweetnessLevel / 5.0,
            bitterness: feedback.bitternessLevel / 5.0,
            body: bodyToDouble(feedback.body)
        )
    }
    
    private static func bodyToDouble(_ body: String?) -> Double {
        guard let body = body?.lowercased() else { return 0.5 }
        switch body {
        case "light", "ligero": return 0.25
        case "medium", "medio": return 0.5
        case "full", "completo": return 0.75
        default: return 0.5
        }
    }
}

/// Complete diagnostic result with unified recommendations (AEC-12 v2)
struct BrewDiagnosticResult {
    let overallAssessment: ExtractionAssessment
    let assessmentConfidence: Double  // 0.0 - 1.0
    let expectedProfile: ExtractionCharacteristics?  // From coffee, if available
    let actualProfile: ActualTasteProfile
    let hasCoffeeContext: Bool
    
    // AEC-12 v2: Unified direction-based output
    let unifiedAdjustment: UnifiedBrewAdjustment
    
    // Legacy: Individual recommendations (kept for backward compat)
    let recommendations: [BrewRecommendation]
    
    /// Get recommendations sorted by priority
    var sortedRecommendations: [BrewRecommendation] {
        recommendations.sorted { $0.priority < $1.priority }
    }
    
    /// Top recommendation (if any)
    var topRecommendation: BrewRecommendation? {
        sortedRecommendations.first
    }
    
    /// Direction from unified adjustment
    var direction: ExtractionDirection {
        unifiedAdjustment.direction
    }
}

// MARK: - Taste Gap Analysis

/// Represents a gap between expected and actual taste
struct TasteGap {
    let dimension: String      // "acidity", "sweetness", etc.
    let expected: Double
    let actual: Double
    let gap: Double            // expected - actual (positive = under, negative = over)
    let significance: GapSignificance
    
    enum GapSignificance {
        case negligible  // |gap| < 0.1
        case minor       // 0.1 <= |gap| < 0.25
        case moderate    // 0.25 <= |gap| < 0.4
        case major       // |gap| >= 0.4
        
        var weight: Int {
            switch self {
            case .negligible: return 0
            case .minor: return 1
            case .moderate: return 2
            case .major: return 3
            }
        }
    }
    
    init(dimension: String, expected: Double, actual: Double) {
        self.dimension = dimension
        self.expected = expected
        self.actual = actual
        self.gap = expected - actual
        
        let absGap = abs(gap)
        if absGap < 0.1 {
            self.significance = .negligible
        } else if absGap < 0.25 {
            self.significance = .minor
        } else if absGap < 0.4 {
            self.significance = .moderate
        } else {
            self.significance = .major
        }
    }
    
    var isUnder: Bool { gap > 0 }  // Expected more than we got
    var isOver: Bool { gap < 0 }   // Got more than expected
}

