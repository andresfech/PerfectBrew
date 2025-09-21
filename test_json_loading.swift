#!/usr/bin/env swift

import Foundation

// BrewingStep struct with audioScript field
struct BrewingStep: Codable {
    let timeSeconds: Int
    let instruction: String
    let shortInstruction: String?
    let audioFileName: String?
    let audioScript: String? // NEW field we're testing
    
    enum CodingKeys: String, CodingKey {
        case timeSeconds = "time_seconds"
        case instruction
        case shortInstruction = "short_instruction"
        case audioFileName = "audio_file_name"
        case audioScript = "audio_script"
    }
    
    // Backward compatibility decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeSeconds = try container.decode(Int.self, forKey: .timeSeconds)
        instruction = try container.decode(String.self, forKey: .instruction)
        shortInstruction = try container.decodeIfPresent(String.self, forKey: .shortInstruction)
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
        audioScript = try container.decodeIfPresent(String.self, forKey: .audioScript)
    }
}

struct RecipeBrewParameters: Codable {
    let coffeeGrams: Double
    let waterGrams: Double
    let ratio: String
    let grindSize: String
    let temperatureCelsius: Double
    let bloomWaterGrams: Double
    let bloomTimeSeconds: Int
    let totalBrewTimeSeconds: Int
    
    enum CodingKeys: String, CodingKey {
        case coffeeGrams = "coffee_grams"
        case waterGrams = "water_grams"
        case ratio
        case grindSize = "grind_size"
        case temperatureCelsius = "temperature_celsius"
        case bloomWaterGrams = "bloom_water_grams"
        case bloomTimeSeconds = "bloom_time_seconds"
        case totalBrewTimeSeconds = "total_brew_time_seconds"
    }
}

struct Recipe: Codable {
    let title: String
    let brewingMethod: String
    let skillLevel: String
    let rating: Double
    let parameters: RecipeBrewParameters
    let preparationSteps: [String]
    let brewingSteps: [BrewingStep]
    let equipment: [String]
    let notes: String
    let servings: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case brewingMethod = "brewing_method"
        case skillLevel = "skill_level"
        case rating
        case parameters
        case preparationSteps = "preparation_steps"
        case brewingSteps = "brewing_steps"
        case equipment
        case notes
        case servings
    }
}

// Test function
func testJSONLoading() {
    print("🧪 Testing Enhanced Recipe JSON Loading...")
    print(String(repeating: "=", count: 50))
    
    let testFiles = [
        ("PerfectBrew/Resources/recipes_aeropress.json", "AeroPress"),
        ("PerfectBrew/Resources/recipes_v60.json", "V60")
    ]
    
    var totalRecipes = 0
    var recipesWithAudioScript = 0
    var recipesWithoutAudioScript = 0
    
    for (filePath, method) in testFiles {
        print("\n📁 Testing \(method) recipes from: \(filePath)")
        
        guard let data = FileManager.default.contents(atPath: filePath) else {
            print("❌ ERROR: Could not read file: \(filePath)")
            continue
        }
        
        do {
            let recipes = try JSONDecoder().decode([Recipe].self, from: data)
            print("✅ Successfully loaded \(recipes.count) \(method) recipes")
            totalRecipes += recipes.count
            
            // Test each recipe
            for (index, recipe) in recipes.enumerated() {
                print("\n  📋 Recipe \(index + 1): \(recipe.title)")
                print("     Brewing steps: \(recipe.brewingSteps.count)")
                
                // Check audioScript field in each brewing step
                var stepsWithAudioScript = 0
                for (stepIndex, step) in recipe.brewingSteps.enumerated() {
                    if let audioScript = step.audioScript {
                        stepsWithAudioScript += 1
                        print("     ✅ Step \(stepIndex + 1): Has audioScript (\(audioScript.count) chars)")
                    } else {
                        print("     ⚪ Step \(stepIndex + 1): No audioScript (backward compatible)")
                    }
                }
                
                if stepsWithAudioScript > 0 {
                    recipesWithAudioScript += 1
                    print("     🎵 Recipe has \(stepsWithAudioScript)/\(recipe.brewingSteps.count) steps with audio scripts")
                } else {
                    recipesWithoutAudioScript += 1
                    print("     📝 Recipe uses backward compatibility (no audio scripts)")
                }
            }
            
        } catch {
            print("❌ ERROR: Failed to decode \(method) recipes: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("   Missing key: \(key) at path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("   Type mismatch for \(type) at path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("   Value not found for \(type) at path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("   Data corrupted at path: \(context.codingPath)")
                @unknown default:
                    print("   Unknown decoding error")
                }
            }
        }
    }
    
    print("\n" + String(repeating: "=", count: 50))
    print("📊 SUMMARY:")
    print("   Total recipes tested: \(totalRecipes)")
    print("   Recipes with audioScript: \(recipesWithAudioScript)")
    print("   Recipes without audioScript: \(recipesWithoutAudioScript)")
    print("   Backward compatibility: \(recipesWithoutAudioScript > 0 ? "✅ Working" : "⚠️  Not tested")")
    print("   New audioScript feature: \(recipesWithAudioScript > 0 ? "✅ Working" : "❌ Not working")")
    
    if totalRecipes > 0 {
        print("\n🎉 JSON loading test completed successfully!")
    } else {
        print("\n❌ JSON loading test failed!")
    }
}

// Run the test
testJSONLoading()
