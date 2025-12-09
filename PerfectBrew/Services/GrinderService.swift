import Foundation

class GrinderService: ObservableObject {
    static let shared = GrinderService()
    
    @Published var availableGrinders: [String] = ["Timemore Chestnut C2s"]
    
    // Cache loaded grinders: [Method: [GrinderName: Grinder]]
    private var grindersCache: [String: [String: Grinder]] = [:]
    
    init() {
        // Fetch remote grinders on init
        // Disabled temporarily for build fix
        /*
        Task {
            await fetchRemoteGrinders()
        }
        */
    }
    
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
    
    private func fetchRemoteGrinders() async {
        // Disabled temporarily for build fix
        /*
        print("🌍 Fetching remote grinders...")
        do {
            let remoteGrinders = try await SupabaseManager.shared.fetchGrinders()
            DispatchQueue.main.async {
                for grinder in remoteGrinders {
                    // Normalize method to match our internal cache keys (e.g. "FrenchPress")
                    let method = self.normalizeMethod(grinder.method)
                    
                    if self.grindersCache[method] == nil {
                        self.grindersCache[method] = [:]
                    }
                    
                    // Cache the remote grinder (overwriting local if exists)
                    self.grindersCache[method]?[grinder.name] = grinder
                    print("✅ Cached remote grinder: \(grinder.name) for \(method)")
                }
            }
        } catch {
            print("❌ Failed to fetch remote grinders: \(error)")
        }
        */
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
            print("DEBUG: Loaded local grinder \(name) for method \(method)")
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
