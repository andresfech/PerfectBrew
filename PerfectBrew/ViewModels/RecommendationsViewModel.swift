import Foundation
import Combine

class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    let coffee: Coffee
    let preferences: UserTastePreferences?
    
    private let recipeDatabase: RecipeDatabase
    private let recommendationService: RecommendationService
    
    init(coffee: Coffee, preferences: UserTastePreferences? = nil, recipeDatabase: RecipeDatabase = .shared, recommendationService: RecommendationService = .shared) {
        self.coffee = coffee
        self.preferences = preferences
        self.recipeDatabase = recipeDatabase
        self.recommendationService = recommendationService
        
        loadRecommendations()
    }
    
    func loadRecommendations() {
        var allRecipes = recipeDatabase.recipes
        
        // Filter by method if method-specific recommendation
        if let prefs = preferences, prefs.recommendationType == .methodSpecific, let method = prefs.selectedMethod {
            allRecipes = allRecipes.filter { $0.brewingMethod == method }
        }
        
        let results = recommendationService.getRecommendations(
            for: coffee,
            from: allRecipes,
            preferences: preferences
        )
        self.recommendations = results
    }
}

