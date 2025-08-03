import Foundation

class BrewSetupViewModel: ObservableObject {
    @Published var coffeeDose: Double = 20.0
    @Published var waterAmount: Double = 340.0
    @Published var waterTemperature: Double = 95.0
    @Published var grindSize: Int = 5
    @Published var brewTime: TimeInterval = 180
    
    init(recipe: Recipe) {
        print("DEBUG: BrewSetupViewModel init with recipe '\(recipe.title)' with \(recipe.parameters.coffeeGrams)g coffee, \(recipe.servings) servings")
        
        // Use the scaled recipe parameters
        self.coffeeDose = recipe.parameters.coffeeGrams
        self.waterAmount = recipe.parameters.waterGrams
        self.waterTemperature = recipe.parameters.temperatureCelsius
        self.brewTime = TimeInterval(recipe.parameters.totalBrewTimeSeconds)
        
        // Convert grind size string to number (approximate)
        self.grindSize = grindSizeToNumber(recipe.parameters.grindSize)
        
        print("DEBUG: BrewSetupViewModel initialized with coffee: \(self.coffeeDose)g, water: \(self.waterAmount)g, temperature: \(self.waterTemperature)°C")
    }
    
    private func grindSizeToNumber(_ grindSize: String) -> Int {
        switch grindSize.lowercased() {
        case "extra fine", "espresso":
            return 1
        case "fine":
            return 2
        case "medium-fine":
            return 3
        case "medium":
            return 5
        case "medium-coarse":
            return 7
        case "coarse":
            return 9
        case "extra coarse":
            return 10
        default:
            return 5
        }
    }
}
