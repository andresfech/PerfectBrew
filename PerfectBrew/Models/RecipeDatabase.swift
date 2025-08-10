import Foundation

class RecipeDatabase: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var recipesByMethod: [String: [Recipe]] = [:]
    
    init() {
        loadAllRecipes()
    }
    
    private func loadAllRecipes() {
        var allRecipes: [Recipe] = []
        
        // Load recipes from each method file
        let methodFiles = [
            "recipes_v60.json": "V60",
            "recipes_frenchpress.json": "French Press",
            "recipes_chemex.json": "Chemex",
            "recipes_aeropress.json": "AeroPress"
        ]
        
        for (filename, method) in methodFiles {
            if let recipes = loadRecipesFromFile(filename) {
                allRecipes.append(contentsOf: recipes)
                recipesByMethod[method] = recipes
                print("Loaded \(recipes.count) recipes for \(method)")
            }
        }
        
        self.recipes = allRecipes
        print("Total recipes loaded: \(allRecipes.count)")
    }
    
    private func loadRecipesFromFile(_ filename: String) -> [Recipe]? {
        guard let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            print("Could not find file: \(filename)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let recipes = try JSONDecoder().decode([Recipe].self, from: data)
            return recipes
        } catch {
            print("Error loading recipes from \(filename): \(error)")
            return nil
        }
    }
    
    func getRecipes(for method: HomeScreen.BrewMethod) -> [Recipe] {
        let methodString = method.rawValue
        return recipesByMethod[methodString] ?? []
    }
    
    func getRecipes(for method: HomeScreen.BrewMethod, servings: Int) -> [Recipe] {
        let methodRecipes = getRecipes(for: method)
        
        // If no recipes found for the method, return empty array
        if methodRecipes.isEmpty {
            print("No recipes found for method: \(method.rawValue)")
            return []
        }
        
        // Group recipes by their base title (removing serving-specific suffixes)
        var recipesByBaseTitle: [String: [Recipe]] = [:]
        
        for recipe in methodRecipes {
            let baseTitle = getBaseTitle(from: recipe.title)
            if recipesByBaseTitle[baseTitle] == nil {
                recipesByBaseTitle[baseTitle] = []
            }
            recipesByBaseTitle[baseTitle]?.append(recipe)
        }
        
        // For each base recipe, find the best match for the requested servings
        var matchingRecipes: [Recipe] = []
        
        for (baseTitle, recipes) in recipesByBaseTitle {
            // First, try to find an exact match for the requested servings
            if let exactMatch = recipes.first(where: { $0.servings == servings }) {
                matchingRecipes.append(exactMatch)
                print("Found exact match for '\(baseTitle)' with \(servings) servings")
            } else {
                // If no exact match, find the closest recipe and scale it
                let closestRecipe = findClosestRecipe(recipes, targetServings: servings)
                let scaledRecipe = closestRecipe.scaledForServings(servings)
                matchingRecipes.append(scaledRecipe)
                print("Scaled '\(baseTitle)' from \(closestRecipe.servings) to \(servings) servings")
            }
        }
        
        print("Found \(matchingRecipes.count) unique recipes for \(method.rawValue) with \(servings) servings")
        return matchingRecipes
    }
    
    // Helper function to extract base title from recipe title
    private func getBaseTitle(from title: String) -> String {
        // Remove common serving suffixes
        let servingSuffixes = [
            " - Single Serve",
            " - Two People", 
            " - Three People",
            " - Four People",
            " - Single",
            " - Two",
            " - Three",
            " - Four"
        ]
        
        var baseTitle = title
        for suffix in servingSuffixes {
            if baseTitle.hasSuffix(suffix) {
                baseTitle = String(baseTitle.dropLast(suffix.count))
                break
            }
        }
        
        return baseTitle
    }
    
    // Helper function to find the closest recipe to the target servings
    private func findClosestRecipe(_ recipes: [Recipe], targetServings: Int) -> Recipe {
        // Prefer recipes with 1 serving as they're easier to scale
        if let singleServing = recipes.first(where: { $0.servings == 1 }) {
            return singleServing
        }
        
        // Otherwise, find the recipe with servings closest to target
        return recipes.min { recipe1, recipe2 in
            abs(recipe1.servings - targetServings) < abs(recipe2.servings - targetServings)
        } ?? recipes.first!
    }
    
    func getAllRecipes() -> [Recipe] {
        return recipes
    }
    
    func searchRecipes(query: String) -> [Recipe] {
        let lowercasedQuery = query.lowercased()
        return recipes.filter { recipe in
            recipe.title.lowercased().contains(lowercasedQuery) ||
            recipe.brewingMethod.lowercased().contains(lowercasedQuery) ||
            recipe.skillLevel.lowercased().contains(lowercasedQuery)
        }
    }
}
