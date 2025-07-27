import Foundation

struct Recipe: Codable, Identifiable {
    var id = UUID()
    let name: String
    let rating: Double
    let difficulty: Difficulty
    let method: BrewMethod
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval
    let description: String
    
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
    
    enum BrewMethod: String, CaseIterable, Codable {
        case v60 = "V60"
        case chemex = "Chemex"
        case frenchPress = "French Press"
        case aeroPress = "AeroPress"
    }
}

// Sample recipes for V60
extension Recipe {
    static let v60Recipes: [Recipe] = [
        Recipe(
            name: "Classic V60",
            rating: 4.5,
            difficulty: .beginner,
            method: .v60,
            coffeeDose: 20.0,
            waterAmount: 340.0,
            waterTemperature: 95.0,
            grindSize: 5,
            brewTime: 180,
            description: "The classic V60 method with balanced flavor profile"
        ),
        Recipe(
            name: "Bright & Fruity",
            rating: 5.0,
            difficulty: .intermediate,
            method: .v60,
            coffeeDose: 18.0,
            waterAmount: 300.0,
            waterTemperature: 92.0,
            grindSize: 4,
            brewTime: 165,
            description: "Highlights bright, fruity notes with lighter roast"
        ),
        Recipe(
            name: "Rich & Bold",
            rating: 3.5,
            difficulty: .advanced,
            method: .v60,
            coffeeDose: 22.0,
            waterAmount: 360.0,
            waterTemperature: 96.0,
            grindSize: 6,
            brewTime: 195,
            description: "Full-bodied brew with deep, rich flavors"
        ),
        Recipe(
            name: "Sweet Spot",
            rating: 5.0,
            difficulty: .intermediate,
            method: .v60,
            coffeeDose: 19.0,
            waterAmount: 320.0,
            waterTemperature: 94.0,
            grindSize: 5,
            brewTime: 175,
            description: "Perfect balance of sweetness and acidity"
        ),
        Recipe(
            name: "Competition",
            rating: 3.0,
            difficulty: .advanced,
            method: .v60,
            coffeeDose: 15.0,
            waterAmount: 250.0,
            waterTemperature: 93.0,
            grindSize: 3,
            brewTime: 150,
            description: "Competition-style brewing for maximum extraction"
        ),
        Recipe(
            name: "Quick Morning",
            rating: 4.0,
            difficulty: .beginner,
            method: .v60,
            coffeeDose: 16.0,
            waterAmount: 270.0,
            waterTemperature: 95.0,
            grindSize: 5,
            brewTime: 120,
            description: "Fast and simple morning brew"
        )
    ]
}
