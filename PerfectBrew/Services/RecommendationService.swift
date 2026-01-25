import Foundation

struct Recommendation: Identifiable, Comparable, Equatable {
    let id = UUID()
    let recipe: Recipe
    let score: Int
    let reasons: [String]
    
    // Sort by score descending
    static func < (lhs: Recommendation, rhs: Recommendation) -> Bool {
        return lhs.score > rhs.score // Higher score first
    }
    
    static func == (lhs: Recommendation, rhs: Recommendation) -> Bool {
        return lhs.id == rhs.id
    }
}

class RecommendationService {
    static let shared = RecommendationService()
    private let ruleEngine = BrewingRuleEngine.shared
    
    // MARK: - Core Logic
    
    func getRecommendations(for coffee: Coffee, from recipes: [Recipe], preferences: UserTastePreferences? = nil) -> [Recommendation] {
        return recipes.compactMap { recipe in
            let result = calculateScore(coffee: coffee, recipe: recipe, preferences: preferences)
            
            // Filter out very poor matches
            if result.score < 10 { return nil }
            
            return Recommendation(recipe: recipe, score: result.score, reasons: result.reasons)
        }.sorted()
    }
    
    private func calculateScore(coffee: Coffee, recipe: Recipe, preferences: UserTastePreferences?) -> (score: Int, reasons: [String]) {
        // 1. Try New Brew Intent Engine
        if let recipeChars = recipe.extractionCharacteristics {
            var target = ruleEngine.computeTargetProfile(for: coffee)
            
            // Adjust target profile based on user preferences
            if let prefs = preferences {
                target = prefs.adjustTargetProfile(target)
            }
            
            return scoreByDistance(target: target, recipe: recipe, recipeChars: recipeChars, preferences: preferences)
        }
        
        // 2. Fallback to Legacy Logic
        return calculateLegacyScore(coffee: coffee, recipe: recipe, preferences: preferences)
    }
    
    // MARK: - New Intent Engine
    
    private func scoreByDistance(target: ExtractionCharacteristics, recipe: Recipe, recipeChars: ExtractionCharacteristics, preferences: UserTastePreferences?) -> (score: Int, reasons: [String]) {
        var reasons: [String] = []
        var score = 100.0
        
        // 1. Vector Distance (Flavor Profile) - 60% of base score
        let clarityDiff = pow(target.clarity - recipeChars.clarity, 2)
        let acidityDiff = pow(target.acidity - recipeChars.acidity, 2)
        let sweetnessDiff = pow(target.sweetness - recipeChars.sweetness, 2)
        let bodyDiff = pow(target.body - recipeChars.body, 2)
        
        let distance = sqrt(clarityDiff + acidityDiff + sweetnessDiff + bodyDiff)
        // Penalty = Distance * 40 (reduced from 60% impact to account for preferences)
        score -= (distance * 24.0) // Reduced from 40.0 to leave room for preference bonuses
        
        if distance < 0.3 {
            reasons.append("Matches Extraction Intent")
        }
        
        // 2. Physical Constraints (Hard Penalties)
        
        // Agitation Penalty
        if recipeChars.agitation.value > target.agitation.value {
            let diff = recipeChars.agitation.value - target.agitation.value
            score -= (diff * 50.0)
            reasons.append("Warning: High agitation risk")
        } else if recipeChars.agitation == target.agitation {
            reasons.append("Optimal Agitation")
        }
        
        // Thermal Penalty
        if recipeChars.thermal.value > target.thermal.value {
            let diff = recipeChars.thermal.value - target.thermal.value
            score -= (diff * 40.0)
            reasons.append("Warning: Temp too high")
        } else if recipeChars.thermal == target.thermal {
            reasons.append("Ideal Temperature Range")
        }
        
        // 3. Preference Alignment Bonus (40% of score)
        if let prefs = preferences {
            let preferenceScore = prefs.calculatePreferenceAlignmentScore(recipe: recipeChars)
            // Add 40% of preference alignment as bonus (0-40 points)
            score += Double(preferenceScore) * 0.4
            
            // Add preference-specific reasons
            if abs(recipeChars.body - prefs.bodyPreference.targetValue) < 0.15 {
                reasons.append("Matches your preference for \(prefs.bodyPreference.rawValue.lowercased()) body")
            }
            if let texture = prefs.bodyTexture {
                let preferredClarity: Double = texture == .teaLike ? 0.8 : 0.4
                if abs(recipeChars.clarity - preferredClarity) < 0.2 {
                    reasons.append("Matches your \(texture.rawValue.lowercased()) preference")
                }
            }
        }
        
        // 4. Method Highlighting Bonus
        let methodHighlight = calculateMethodHighlighting(recipe: recipe, target: target, preferences: preferences)
        score += methodHighlight.bonus
        reasons.append(contentsOf: methodHighlight.reasons)
        
        // 5. Highlight specific matches
        if abs(target.clarity - recipeChars.clarity) < 0.1 && target.clarity > 0.7 {
            reasons.append("High Clarity Match")
        }
        if abs(target.body - recipeChars.body) < 0.1 && target.body > 0.7 {
            reasons.append("High Body Match")
        }
        
        return (Int(max(0, min(100, score))), reasons)
    }
    
    // MARK: - Method Highlighting
    
    private func calculateMethodHighlighting(recipe: Recipe, target: ExtractionCharacteristics, preferences: UserTastePreferences?) -> (bonus: Double, reasons: [String]) {
        var bonus = 0.0
        var reasons: [String] = []
        
        // Method capability matrix
        let methodCapabilities: [String: ExtractionCharacteristics] = [
            "V60": ExtractionCharacteristics(clarity: 0.9, acidity: 0.8, sweetness: 0.6, body: 0.3, agitation: .medium, thermal: .high),
            "AeroPress": ExtractionCharacteristics(clarity: 0.6, acidity: 0.7, sweetness: 0.7, body: 0.6, agitation: .medium, thermal: .medium),
            "French Press": ExtractionCharacteristics(clarity: 0.2, acidity: 0.4, sweetness: 0.7, body: 0.9, agitation: .low, thermal: .medium),
            "Chemex": ExtractionCharacteristics(clarity: 0.95, acidity: 0.85, sweetness: 0.6, body: 0.2, agitation: .medium, thermal: .high)
        ]
        
        guard let methodProfile = methodCapabilities[recipe.brewingMethod] else {
            return (0.0, [])
        }
        
        // Find coffee's dominant characteristic
        let characteristics: [(String, Double)] = [
            ("clarity", target.clarity),
            ("acidity", target.acidity),
            ("body", target.body),
            ("sweetness", target.sweetness)
        ]
        let dominant = characteristics.max(by: { $0.1 < $1.1 })!
        
        // Check if method aligns with coffee's dominant characteristic
        let methodValue: Double
        switch dominant.0 {
        case "clarity": methodValue = methodProfile.clarity
        case "acidity": methodValue = methodProfile.acidity
        case "body": methodValue = methodProfile.body
        case "sweetness": methodValue = methodProfile.sweetness
        default: methodValue = 0.5
        }
        
        if methodValue > 0.6 && dominant.1 > 0.6 {
            bonus += 15.0
            if dominant.0 == "clarity" {
                reasons.append("V60 highlights coffee's brightness")
            } else if dominant.0 == "body" {
                reasons.append("French Press emphasizes body")
            } else if dominant.0 == "acidity" {
                reasons.append("Method highlights fruity notes")
            }
        }
        
        // Check if method aligns with user preferences
        if let prefs = preferences {
            let preferenceMatch = prefs.calculatePreferenceAlignmentScore(recipe: methodProfile)
            if preferenceMatch > 70 {
                bonus += 10.0
                reasons.append("Method aligns with your preferences")
            }
        }
        
        return (bonus, reasons)
    }
    
    // MARK: - Legacy Logic
    
    private func calculateLegacyScore(coffee: Coffee, recipe: Recipe, preferences: UserTastePreferences?) -> (score: Int, reasons: [String]) {
        var score = 0
        var reasons: [String] = []
        
        guard let profile = recipe.recipeProfile else {
            return (30, ["General recommendation"])
        }
        
        // Roast Match (50 pts)
        if profile.recommendedRoastLevels.contains(coffee.roastLevel) {
            score += 50
            reasons.append("Matches \(coffee.roastLevel.rawValue) roast")
        } else if profile.recommendedRoastLevels.isEmpty {
            score += 30
        }
        
        // Process Match (30 pts)
        if profile.recommendedProcesses.contains(coffee.process) {
            score += 30
            reasons.append("Best for \(coffee.process.rawValue) process")
        }
        
        // Origin/Variety/Tags Bonus
        // ... simplified for legacy fallback ...
        
        return (score, reasons)
    }
}
