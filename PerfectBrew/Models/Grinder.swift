import Foundation

struct GrinderSettings: Codable {
    let `default`: String
    let recipes: [String: String]
}

struct Grinder: Codable, Identifiable {
    var id: String { name + "_" + method }
    let name: String
    let method: String
    let settings: GrinderSettings
    
    func getSetting(for recipeTitle: String) -> String {
        return settings.recipes[recipeTitle] ?? settings.default
    }
}

