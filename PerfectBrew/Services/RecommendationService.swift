import Foundation

struct Recommendation: Identifiable, Comparable {
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
    
    // MARK: - Core Logic
    
    func getRecommendations(for coffee: Coffee, from recipes: [Recipe]) -> [Recommendation] {
        return recipes.compactMap { recipe in
            // Filter out recipes that are strictly incompatible? 
            // For now, we score everything and let sorting handle it.
            let result = calculateScore(coffee: coffee, recipe: recipe)
            
            // Filter out very poor matches (optional)
            if result.score < 10 { return nil }
            
            return Recommendation(recipe: recipe, score: result.score, reasons: result.reasons)
        }.sorted()
    }
    
    private func calculateScore(coffee: Coffee, recipe: Recipe) -> (score: Int, reasons: [String]) {
        var score = 0
        var reasons: [String] = []
        
        // If recipe has no profile, give it a baseline neutral score so it appears but below specific matches
        guard let profile = recipe.recipeProfile else {
            return (score: 30, reasons: ["General recommendation"])
        }
        
        // 1. Roast Match (Max 50 points)
        if profile.recommendedRoastLevels.contains(coffee.roastLevel) {
            score += 50
            reasons.append("Matches \(coffee.roastLevel.rawValue) roast")
        } else if profile.recommendedRoastLevels.isEmpty {
            // Flexible recipe
            score += 30
        } else {
            // Mismatch penalty (implicit: score doesn't increase)
        }
        
        // 2. Process Match (Max 30 points)
        if profile.recommendedProcesses.contains(coffee.process) {
            score += 30
            reasons.append("Best for \(coffee.process.rawValue) process")
        } else if profile.recommendedProcesses.isEmpty {
            score += 15
        }
        
        // 3. Flavor Tags (Max 20 points)
        // Check overlap
        let matchingTags = Set(coffee.flavorTags.map { $0.rawValue }).intersection(Set(profile.recommendedFlavorTags.map { $0.rawValue }))
        
        if !matchingTags.isEmpty {
            let pointsPerTag = 10
            let tagBonus = min(20, matchingTags.count * pointsPerTag)
            score += tagBonus
            
            // Format tag reasons
            let tagsList = matchingTags.joined(separator: ", ")
            reasons.append("Highlights: \(tagsList)")
        }
        
        return (score, reasons)
    }
}

