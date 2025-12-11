import Foundation

struct DiagnosticRule: Codable {
    let problem: String
    let diagnosis: String
    let description: String
    let fixes: [String: [String]]
}

struct BrewAdvice {
    let diagnosis: String
    let action: String
    let reason: String
}

class DiagnosticService {
    static let shared = DiagnosticService()
    
    private var rules: [String: DiagnosticRule] = [:]
    
    init() {
        loadRules()
    }
    
    private func loadRules() {
        // Try multiple paths just in case
        let candidates = [
            Bundle.main.url(forResource: "BrewingDiagnostics", withExtension: "json"),
            Bundle.main.url(forResource: "BrewingDiagnostics", withExtension: "json", subdirectory: "KnowledgeBase"),
            Bundle.main.url(forResource: "BrewingDiagnostics", withExtension: "json", subdirectory: "Resources/KnowledgeBase")
        ]
        
        guard let url = candidates.compactMap({ $0 }).first else {
            print("❌ DiagnosticService: BrewingDiagnostics.json not found in Bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            rules = try JSONDecoder().decode([String: DiagnosticRule].self, from: data)
            print("✅ DiagnosticService: Loaded \(rules.count) rules")
        } catch {
            print("❌ DiagnosticService: Failed to decode rules - \(error)")
        }
    }
    
    func diagnose(defect: String, method: String) -> BrewAdvice? {
        guard let rule = rules[defect.lowercased()] else { return nil }
        
        // Normalize method key
        // Keys in JSON: "V60", "AeroPress", "French Press", "Chemex", "default"
        // Method input might be "V60", "French Press", etc.
        
        var bestFixes: [String] = []
        
        // Exact match
        if let specificFixes = rule.fixes.first(where: { $0.key.caseInsensitiveCompare(method) == .orderedSame })?.value {
            bestFixes = specificFixes
        } else {
            // Partial match (e.g. "AeroPress Inverted" -> "AeroPress")
            if let partialKey = rule.fixes.keys.first(where: { method.localizedCaseInsensitiveContains($0) }) {
                bestFixes = rule.fixes[partialKey] ?? []
            } else {
                bestFixes = rule.fixes["default"] ?? []
            }
        }
        
        let action = bestFixes.first ?? "Check brewing variables"
        
        return BrewAdvice(
            diagnosis: rule.diagnosis,
            action: action,
            reason: rule.description
        )
    }
    
    // Get all available defects for UI picker
    func getAvailableDefects() -> [String] {
        // Return keys sorted, maybe filtered to remove internal IDs if any
        return ["sour", "bitter", "weak", "strong", "hollow"]
    }
    
    // UI Friendly Name mapping
    func getDefectDisplayName(_ key: String) -> String {
        return rules[key]?.problem ?? key.capitalized
    }
}

