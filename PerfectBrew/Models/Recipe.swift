import Foundation

struct Recipe: Codable, Identifiable {
    var id = UUID()
    let title: String
    let brewingMethod: String
    let skillLevel: String
    let rating: Double
    let parameters: RecipeBrewParameters
    let preparationSteps: [String]
    let brewingSteps: [BrewingStep]
    let equipment: [String]
    let notes: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case brewingMethod = "brewing_method"
        case skillLevel = "skill_level"
        case rating
        case parameters
        case preparationSteps = "preparation_steps"
        case brewingSteps = "brewing_steps"
        case steps // For backward compatibility in decoding only
        case equipment
        case notes
    }
    
    // Backward compatibility - if only 'steps' is provided, treat them as brewing steps
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        brewingMethod = try container.decode(String.self, forKey: .brewingMethod)
        skillLevel = try container.decode(String.self, forKey: .skillLevel)
        rating = try container.decode(Double.self, forKey: .rating)
        parameters = try container.decode(RecipeBrewParameters.self, forKey: .parameters)
        equipment = try container.decode([String].self, forKey: .equipment)
        notes = try container.decode(String.self, forKey: .notes)
        
        // Try to decode new structure first
        if let prepSteps = try? container.decode([String].self, forKey: .preparationSteps),
           let brewSteps = try? container.decode([BrewingStep].self, forKey: .brewingSteps) {
            preparationSteps = prepSteps
            brewingSteps = brewSteps
        } else {
            // Fallback to old structure - treat all steps as brewing steps
            let oldSteps = try container.decode([String].self, forKey: .steps)
            preparationSteps = []
            brewingSteps = oldSteps.enumerated().map { index, step in
                BrewingStep(
                    timeSeconds: index * 30, // Estimate timing
                    instruction: step
                )
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(brewingMethod, forKey: .brewingMethod)
        try container.encode(skillLevel, forKey: .skillLevel)
        try container.encode(rating, forKey: .rating)
        try container.encode(parameters, forKey: .parameters)
        try container.encode(preparationSteps, forKey: .preparationSteps)
        try container.encode(brewingSteps, forKey: .brewingSteps)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(notes, forKey: .notes)
    }
    
    // Regular initializer for creating instances in previews and tests
    init(title: String, brewingMethod: String, skillLevel: String, rating: Double, parameters: RecipeBrewParameters, preparationSteps: [String], brewingSteps: [BrewingStep], equipment: [String], notes: String) {
        self.title = title
        self.brewingMethod = brewingMethod
        self.skillLevel = skillLevel
        self.rating = rating
        self.parameters = parameters
        self.preparationSteps = preparationSteps
        self.brewingSteps = brewingSteps
        self.equipment = equipment
        self.notes = notes
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

struct BrewingStep: Codable {
    let timeSeconds: Int
    let instruction: String
    
    enum CodingKeys: String, CodingKey {
        case timeSeconds = "time_seconds"
        case instruction
    }
}

struct BrewParameters: Codable {
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval
    
    static let sampleBrewParameters = BrewParameters(
        coffeeDose: 18.0,
        waterAmount: 190.0,
        waterTemperature: 95.0,
        grindSize: 7,
        brewTime: 180.0
    )
}

struct RecipeBrewParameters: Codable {
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

// Sample recipe for previews and fallback
extension Recipe {
    static let sampleRecipe = Recipe(
        title: "Sample V60",
        brewingMethod: "V60",
        skillLevel: "Beginner",
        rating: 4.5,
        parameters: RecipeBrewParameters(
            coffeeGrams: 16.0,
            waterGrams: 256.0,
            ratio: "1:16",
            grindSize: "Medium-fine (like table salt)",
            temperatureCelsius: 96.0,
            bloomWaterGrams: 40.0,
            bloomTimeSeconds: 45,
            totalBrewTimeSeconds: 210
        ),
        preparationSteps: [
            "Heat water to 96°C",
            "Place filter in V60 and rinse with hot water",
            "Add 16g of ground coffee"
        ],
        brewingSteps: [
            BrewingStep(timeSeconds: 0, instruction: "Bloom: Pour 40mL of water and swirl gently"),
            BrewingStep(timeSeconds: 45, instruction: "Main pour: Add remaining water in circular motion"),
            BrewingStep(timeSeconds: 120, instruction: "Final swirl to flatten the bed"),
            BrewingStep(timeSeconds: 210, instruction: "Enjoy your coffee!")
        ],
        equipment: ["V60", "Paper filter", "Kettle", "Scale", "Grinder"],
        notes: "A simple and delicious V60 recipe for beginners."
    )
}
