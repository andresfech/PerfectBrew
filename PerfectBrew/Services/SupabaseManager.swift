import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        print("DEBUG: SupabaseManager init (Active)")
        
        let supabaseUrl = URL(string: "https://fimzbgfmforervajguoa.supabase.co")!
        let supabaseKey = "sb_publishable_wI4HtzYkifad4f83xMXI9g_uJzQCXp-"
        
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
    
    // MARK: - Recipes
    func fetchRecipes() async throws -> [Recipe] {
        let response: [RecipeDBModel] = try await client
            .from("recipes")
            .select()
            .execute()
            .value
            
        return response.map { $0.toRecipe() }
    }
    
    // MARK: - Grinders
    func fetchGrinders() async throws -> [Grinder] {
        let response: [GrinderDBModel] = try await client
            .from("grinders")
            .select()
            .execute()
            .value
            
        return response.map { $0.toGrinder() }
    }
}

// Keeping structs for compatibility
struct RecipeDBModel: Codable {
    let id: UUID
    let title: String
    let method: String
    let jsonData: Recipe
    
    enum CodingKeys: String, CodingKey {
        case id, title, method
        case jsonData = "json_data"
    }
    func toRecipe() -> Recipe { return jsonData }
}

struct GrinderDBModel: Codable {
    let id: UUID
    let name: String
    let method: String
    let settingsJson: GrinderSettings
    
    enum CodingKeys: String, CodingKey {
        case id, name, method
        case settingsJson = "settings_json"
    }
    func toGrinder() -> Grinder {
        return Grinder(name: name, method: method, settings: settingsJson)
    }
}
