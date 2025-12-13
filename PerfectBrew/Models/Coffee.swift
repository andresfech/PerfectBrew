import Foundation

enum RoastLevel: String, CaseIterable, Codable, Identifiable {
    case light = "Light"
    case medium = "Medium"
    case dark = "Dark"
    
    var id: String { rawValue }
}

enum Process: String, CaseIterable, Codable, Identifiable {
    case washed = "Washed"
    case natural = "Natural"
    case honey = "Honey"
    case anaerobic = "Anaerobic"
    case other = "Other"
    
    var id: String { rawValue }
}

enum FlavorTag: String, CaseIterable, Codable, Identifiable {
    // Original flavor descriptors
    case fruity = "Fruity"
    case floral = "Floral"
    case nutty = "Nutty"
    case chocolate = "Chocolate"
    case sweet = "Sweet"
    case citrus = "Citrus"
    case acidity = "Acidity"
    case berry = "Berry"
    case spicy = "Spicy"
    case savory = "Savory"
    case tea = "Tea-like"
    case caramel = "Caramel"
    case stoneFruit = "Stone Fruit"
    case tropical = "Tropical"
    case fermented = "Fermented"
    case vanilla = "Vanilla"
    case earthy = "Earthy"
    case roasted = "Roasted"
    case herbaceous = "Herbaceous"
    
    // Brew profile descriptors (used in recipe_profile)
    case complex = "Complex"
    case silky = "Silky"
    case clean = "Clean"
    case rich = "Rich"
    case bright = "Bright"
    case balanced = "Balanced"
    case strong = "Strong"
    case espressoLike = "Espresso-like"
    case elegant = "Elegant"
    case intense = "Intense"
    case smooth = "Smooth"
    case lowAcidity = "Low Acidity"
    case nuanced = "Nuanced"
    case delicate = "Delicate"
    case aromatic = "Aromatic"
    case vibrant = "Vibrant"
    case bold = "Bold"
    case creamy = "Creamy"
    case crisp = "Crisp"
    case fullBodied = "Full-bodied"
    case lightBodied = "Light-bodied"
    case mellow = "Mellow"
    case punchy = "Punchy"
    case refined = "Refined"
    case structured = "Structured"
    case syrupy = "Syrupy"
    case winey = "Winey"
    case juicy = "Juicy"
    case clarityFocused = "Clarity-focused"
    
    // Additional brew descriptors
    case thick = "Thick"
    case reliable = "Reliable"
    case round = "Round"
    case classic = "Classic"
    case layered = "Layered"
    case clarified = "Clarified"
    case deep = "Deep"
    case highAcidity = "High Acidity"
    case consistent = "Consistent"
    case artisan = "Artisan"
    case sustainable = "Sustainable"
    
    var id: String { rawValue }
}

struct Coffee: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var roaster: String
    var roastLevel: RoastLevel
    var process: Process
    var flavorTags: [FlavorTag]
    var notes: String
    
    // New Fields
    var country: String
    var region: String
    var variety: String
    var altitude: String
    var roastDate: Date?
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Default empty init
    init(
        id: UUID = UUID(),
        name: String = "",
        roaster: String = "",
        roastLevel: RoastLevel = .medium,
        process: Process = .washed,
        flavorTags: [FlavorTag] = [],
        notes: String = "",
        country: String = "",
        region: String = "",
        variety: String = "",
        altitude: String = "",
        roastDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.roaster = roaster
        self.roastLevel = roastLevel
        self.process = process
        self.flavorTags = flavorTags
        self.notes = notes
        self.country = country
        self.region = region
        self.variety = variety
        self.altitude = altitude
        self.roastDate = roastDate
    }
}
