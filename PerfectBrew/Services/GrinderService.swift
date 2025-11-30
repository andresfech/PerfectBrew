import Foundation

class GrinderService: ObservableObject {
    static let shared = GrinderService()
    
    @Published var availableGrinders: [String] = ["Timemore Chestnut C2s"]
    
    // Cache loaded grinders: [Method: [GrinderName: Grinder]]
    private var grindersCache: [String: [String: Grinder]] = [:]
    
    init() {}
    
    func getSetting(for grinderName: String, recipe: Recipe) -> String {
        let method = normalizeMethod(recipe.brewingMethod)
        
        // Load grinder if not cached
        if grindersCache[method] == nil || grindersCache[method]?[grinderName] == nil {
            loadGrinder(name: grinderName, method: method)
        }
        
        guard let grinder = grindersCache[method]?[grinderName] else {
            return recipe.parameters.grindSize // Fallback to generic description
        }
        
        return grinder.getSetting(for: recipe.title)
    }
    
    private func loadGrinder(name: String, method: String) {
        let cleanName = name.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(method)_\(cleanName)"
        let resourcePath = "Grinders/\(method)"
        
        var fileUrl: URL?
        
        // Try with specific subdirectory
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: resourcePath) {
            fileUrl = url
        } 
        // Try flattened in bundle
        else if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            fileUrl = url
        }
        
        guard let url = fileUrl else {
            print("DEBUG: Grinder file not found: \(fileName) in \(resourcePath) or root")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let grinder = try JSONDecoder().decode(Grinder.self, from: data)
            
            if grindersCache[method] == nil {
                grindersCache[method] = [:]
            }
            grindersCache[method]?[name] = grinder
            print("DEBUG: Loaded grinder \(name) for method \(method)")
        } catch {
            print("DEBUG: Failed to decode grinder \(name): \(error)")
        }
    }
    
    private func normalizeMethod(_ method: String) -> String {
        // Ensure method names match folder names
        if method.lowercased().contains("aeropress") {
            return "AeroPress"
        } else if method.lowercased().contains("v60") {
            return "V60"
        } else if method.lowercased().contains("french") {
            return "FrenchPress"
        }
        return method
    }
}

