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
    
    func getRecommendations(for coffee: Coffee, from recipes: [Recipe]) -> [Recommendation] {
        return recipes.compactMap { recipe in
            // Filter out recipes that are strictly incompatible? 
            let result = calculateScore(coffee: coffee, recipe: recipe)
            
            // Filter out very poor matches
            if result.score < 10 { return nil }
            
            return Recommendation(recipe: recipe, score: result.score, reasons: result.reasons)
        }.sorted()
    }
    
    private func calculateScore(coffee: Coffee, recipe: Recipe) -> (score: Int, reasons: [String]) {
        // 1. Try New Brew Intent Engine
        if let recipeChars = recipe.extractionCharacteristics {
            let target = ruleEngine.computeTargetProfile(for: coffee)
            return scoreByDistance(target: target, recipe: recipeChars)
        }
        
        // 2. Fallback to Legacy Logic
        return calculateLegacyScore(coffee: coffee, recipe: recipe)
    }
    
    // MARK: - New Intent Engine
    
    private func scoreByDistance(target: ExtractionCharacteristics, recipe: ExtractionCharacteristics) -> (score: Int, reasons: [String]) {
        var reasons: [String] = []
        var score = 100.0
        
        // 1. Vector Distance (Flavor Profile)
        let clarityDiff = pow(target.clarity - recipe.clarity, 2)
        let acidityDiff = pow(target.acidity - recipe.acidity, 2)
        let sweetnessDiff = pow(target.sweetness - recipe.sweetness, 2)
        let bodyDiff = pow(target.body - recipe.body, 2)
        
        let distance = sqrt(clarityDiff + acidityDiff + sweetnessDiff + bodyDiff)
        // Max distance is approx sqrt(4) = 2.0. Scale to impact score.
        // We want tight match. 0.5 distance is okay. 1.0 is bad.
        // Penalty = Distance * 40
        score -= (distance * 40.0)
        
        if distance < 0.3 {
            reasons.append("Matches Extraction Intent")
        }
        
        // 2. Physical Constraints (Hard Penalties)
        
        // Agitation Penalty
        if recipe.agitation.value > target.agitation.value {
            // Recipe uses High Agitation but Target requires Low (e.g. Naturals)
            let diff = recipe.agitation.value - target.agitation.value
            score -= (diff * 50.0) // Severe penalty
            reasons.append("Warning: High agitation risk")
        } else if recipe.agitation == target.agitation {
            reasons.append("Optimal Agitation")
        }
        
        // Thermal Penalty
        if recipe.thermal.value > target.thermal.value {
            // Recipe uses High Heat but Target requires Low (e.g. Dark Roast)
            let diff = recipe.thermal.value - target.thermal.value
            score -= (diff * 40.0)
            reasons.append("Warning: Temp too high")
        } else if recipe.thermal == target.thermal {
            reasons.append("Ideal Temperature Range")
        }
        
        // 3. Highlight specific matches
        if abs(target.clarity - recipe.clarity) < 0.1 && target.clarity > 0.7 {
            reasons.append("High Clarity Match")
        }
        if abs(target.body - recipe.body) < 0.1 && target.body > 0.7 {
            reasons.append("High Body Match")
        }
        
        return (Int(max(0, min(100, score))), reasons)
    }
    
    // MARK: - Legacy Logic
    
    private func calculateLegacyScore(coffee: Coffee, recipe: Recipe) -> (score: Int, reasons: [String]) {
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
