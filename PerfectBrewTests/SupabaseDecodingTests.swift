import XCTest
@testable import PerfectBrew

final class SupabaseDecodingTests: XCTestCase {

    // Test that the intermediate struct RecipeDBModel correctly decodes
    // a JSON payload that mimics what Supabase returns (nested JSONB).
    func testRecipeDBModelDecoding() throws {
        let jsonString = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "title": "Test Recipe",
            "method": "AeroPress",
            "json_data": {
                "title": "Test Recipe",
                "brewing_method": "AeroPress",
                "skill_level": "Beginner",
                "rating": 5.0,
                "parameters": {
                    "coffee_grams": 15,
                    "water_grams": 250,
                    "ratio": "1:16.6",
                    "grind_size": "Medium",
                    "temperature_celsius": 90,
                    "bloom_water_grams": 0,
                    "bloom_time_seconds": 0,
                    "total_brew_time_seconds": 120
                },
                "preparation_steps": ["Step 1"],
                "brewing_steps": [],
                "equipment": [],
                "notes": "Test notes",
                "servings": 1
            }
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // When decoding the intermediate model
        let dbModel = try decoder.decode(RecipeDBModel.self, from: data)
        
        // Then the extracted recipe should be valid
        let recipe = dbModel.toRecipe()
        
        XCTAssertEqual(recipe.title, "Test Recipe")
        XCTAssertEqual(recipe.brewingMethod, "AeroPress")
        XCTAssertEqual(recipe.parameters.coffeeGrams, 15)
        XCTAssertEqual(recipe.notes, "Test notes")
    }
}

