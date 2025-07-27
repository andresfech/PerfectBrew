import Foundation

struct Recipe: Codable, Identifiable {
    var id = UUID()
    let title: String
    let brewingMethod: String
    let skillLevel: String
    let rating: Double
    let parameters: BrewParameters
    let steps: [String]
    let equipment: [String]
    let notes: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case brewingMethod = "brewing_method"
        case skillLevel = "skill_level"
        case rating
        case parameters
        case steps
        case equipment
        case notes
    }
    
    var difficulty: Difficulty {
        switch skillLevel.lowercased() {
        case "beginner":
            return .beginner
        case "intermediate":
            return .intermediate
        case "advanced":
            return .advanced
        default:
            return .beginner
        }
    }
    
    var difficultyColor: String {
        switch difficulty {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

struct BrewParameters: Codable {
    let coffeeGrams: Double
    let waterGrams: Double
    let ratio: String
    let grindSize: String
    let temperatureCelsius: Double
    let bloomWaterGrams: Double
    let bloomTimeSeconds: Int
    let totalBrewTimeSeconds: Int
    
    enum CodingKeys: String, CodingKey {
        case coffeeGrams = "coffee_grams"
        case waterGrams = "water_grams"
        case ratio
        case grindSize = "grind_size"
        case temperatureCelsius = "temperature_celsius"
        case bloomWaterGrams = "bloom_water_grams"
        case bloomTimeSeconds = "bloom_time_seconds"
        case totalBrewTimeSeconds = "total_brew_time_seconds"
    }
}

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

// Recipe Database Service
class RecipeDatabase: ObservableObject {
    @Published var recipes: [Recipe] = []
    
    init() {
        loadRecipes()
    }
    
    func loadRecipes() {
        print("RecipeDatabase: Loading recipes...")
        if let url = Bundle.main.url(forResource: "recipes", withExtension: "json") {
            print("RecipeDatabase: Found JSON file at \(url)")
            do {
                let data = try Data(contentsOf: url)
                print("RecipeDatabase: Loaded \(data.count) bytes")
                let decoder = JSONDecoder()
                recipes = try decoder.decode([Recipe].self, from: data)
                print("RecipeDatabase: Successfully loaded \(recipes.count) recipes")
                for recipe in recipes {
                    print("RecipeDatabase: - \(recipe.title) (\(recipe.brewingMethod))")
                }
            } catch {
                print("RecipeDatabase: Error loading recipes: \(error)")
                recipes = []
            }
        } else {
            print("RecipeDatabase: Could not find recipes.json in bundle")
            recipes = []
        }
    }
    
    func getRecipes(for method: String) -> [Recipe] {
        return recipes.filter { $0.brewingMethod.lowercased() == method.lowercased() }
    }
    
    func getRecipes(for method: HomeScreen.BrewMethod) -> [Recipe] {
        return getRecipes(for: method.rawValue)
    }
    
    func getV60Recipes() -> [Recipe] {
        return getRecipes(for: "V60")
    }
    
    func getChemexRecipes() -> [Recipe] {
        return getRecipes(for: "Chemex")
    }
    
    func getFrenchPressRecipes() -> [Recipe] {
        return getRecipes(for: "French Press")
    }
    
    func getAeroPressRecipes() -> [Recipe] {
        return getRecipes(for: "AeroPress")
    }
    
    func getRecipesByDifficulty(for method: String, difficulty: Difficulty) -> [Recipe] {
        return recipes.filter { 
            $0.brewingMethod.lowercased() == method.lowercased() && 
            $0.difficulty == difficulty 
        }
    }
    
    func searchRecipes(query: String) -> [Recipe] {
        if query.isEmpty {
            return recipes
        }
        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(query) ||
            recipe.brewingMethod.localizedCaseInsensitiveContains(query) ||
            recipe.skillLevel.localizedCaseInsensitiveContains(query)
        }
    }
}
