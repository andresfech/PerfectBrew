import Foundation
import Combine

class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    let coffee: Coffee
    
    private let recipeDatabase: RecipeDatabase
    private let recommendationService: RecommendationService
    
    init(coffee: Coffee, recipeDatabase: RecipeDatabase = .shared, recommendationService: RecommendationService = .shared) {
        self.coffee = coffee
        self.recipeDatabase = recipeDatabase
        self.recommendationService = recommendationService
        
        loadRecommendations()
    }
    
    func loadRecommendations() {
        // Flatten all recipes from database
        let allRecipes = recipeDatabase.recipes
        
        let results = recommendationService.getRecommendations(for: coffee, from: allRecipes)
        self.recommendations = results
    }
}

