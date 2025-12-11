import Foundation

class KnowledgeBaseService: ObservableObject {
    static let shared = KnowledgeBaseService()
    
    @Published var varietyProfiles: [String: VarietyProfile] = [:]
    @Published var processProfiles: [String: ProcessProfile] = [:]
    
    private init() {
        print("📚 KnowledgeBaseService: Initialized")
        loadKnowledgeBase()
    }
    
    func loadKnowledgeBase() {
        loadVarietyProfiles()
        loadProcessProfiles()
    }
    
    private func loadVarietyProfiles() {
        guard let url = Bundle.main.url(forResource: "VarietyProfiles", withExtension: "json") else {
            print("⚠️ VarietyProfiles.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let profiles = try JSONDecoder().decode([VarietyProfile].self, from: data)
            // Normalize keys to lowercase for easier lookup
            self.varietyProfiles = Dictionary(uniqueKeysWithValues: profiles.map { ($0.variety.lowercased(), $0) })
            print("✅ Loaded \(profiles.count) variety profiles")
        } catch {
            print("❌ Failed to decode VarietyProfiles.json: \(error)")
        }
    }
    
    private func loadProcessProfiles() {
        guard let url = Bundle.main.url(forResource: "ProcessProfiles", withExtension: "json") else {
            print("⚠️ ProcessProfiles.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let profiles = try JSONDecoder().decode([ProcessProfile].self, from: data)
            self.processProfiles = Dictionary(uniqueKeysWithValues: profiles.map { ($0.process.lowercased(), $0) })
            print("✅ Loaded \(profiles.count) process profiles")
        } catch {
            print("❌ Failed to decode ProcessProfiles.json: \(error)")
        }
    }
    
    func getVarietyProfile(for variety: String) -> VarietyProfile? {
        let normalized = variety.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Direct lookup
        if let profile = varietyProfiles[normalized] {
            return profile
        }
        
        // Fuzzy lookup (contains)
        // e.g. "Panama Geisha" contains "geisha"
        return varietyProfiles.values.first { profile in
            normalized.contains(profile.variety.lowercased()) || 
            profile.variety.lowercased().contains(normalized)
        }
    }
    
    func getProcessProfile(for process: String) -> ProcessProfile? {
        let normalized = process.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Direct lookup
        if let profile = processProfiles[normalized] {
            return profile
        }
        
        // Fuzzy lookup
        return processProfiles.values.first { profile in
            normalized.contains(profile.process.lowercased())
        }
    }
}
