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
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Default empty init
    init(id: UUID = UUID(), name: String = "", roaster: String = "", roastLevel: RoastLevel = .medium, process: Process = .washed, flavorTags: [FlavorTag] = [], notes: String = "") {
        self.id = id
        self.name = name
        self.roaster = roaster
        self.roastLevel = roastLevel
        self.process = process
        self.flavorTags = flavorTags
        self.notes = notes
    }
}

