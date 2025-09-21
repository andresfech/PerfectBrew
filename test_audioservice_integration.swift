#!/usr/bin/env swift

import Foundation

// Simplified BrewingStep struct matching the iOS app
struct BrewingStep: Codable {
    let timeSeconds: Int
    let instruction: String
    let shortInstruction: String?
    let audioFileName: String?
    let audioScript: String?
    
    enum CodingKeys: String, CodingKey {
        case timeSeconds = "time_seconds"
        case instruction
        case shortInstruction = "short_instruction"
        case audioFileName = "audio_file_name"
        case audioScript = "audio_script"
    }
}

// Test AudioService integration with enhanced recipes
class AudioServiceIntegrationTest {
    
    func testEnhancedRecipeIntegration() {
        print("🎵 Testing AudioService Integration with Enhanced Recipes")
        print(String(repeating: "=", count: 60))
        
        // Test 1: Load enhanced AeroPress recipe and verify audioScript fields
        print("\n📋 Test 1: Enhanced Recipe Loading")
        testEnhancedRecipeLoading()
        
        // Test 2: Simulate AudioService audio file path resolution
        print("\n🔍 Test 2: Audio File Path Resolution")
        testAudioPathResolution()
        
        // Test 3: Test backward compatibility with non-enhanced recipes
        print("\n🔄 Test 3: Backward Compatibility")
        testBackwardCompatibility()
        
        print("\n" + String(repeating: "=", count: 60))
        print("🎉 AudioService integration test completed!")
    }
    
    func testEnhancedRecipeLoading() {
        // Load the enhanced AeroPress recipe JSON
        let jsonPath = "PerfectBrew/Resources/recipes_aeropress.json"
        
        guard let jsonData = FileManager.default.contents(atPath: jsonPath) else {
            print("❌ Could not load recipe JSON file")
            return
        }
        
        do {
            let recipes = try JSONDecoder().decode([Recipe].self, from: jsonData)
            
            // Find James Hoffmann recipe
            guard let jamesRecipe = recipes.first(where: { $0.title.contains("James Hoffmann") }) else {
                print("❌ Could not find James Hoffmann recipe")
                return
            }
            
            print("✅ Successfully loaded enhanced recipe: \(jamesRecipe.title)")
            print("   Brewing steps: \(jamesRecipe.brewingSteps.count)")
            
            // Check each brewing step for audioScript
            var stepsWithAudioScript = 0
            for (index, step) in jamesRecipe.brewingSteps.enumerated() {
                if let audioScript = step.audioScript {
                    stepsWithAudioScript += 1
                    print("   Step \(index + 1): ✅ Has audioScript (\(audioScript.count) chars)")
                    
                    // Verify it's different from instruction
                    if audioScript != step.instruction {
                        print("     ✅ AudioScript is enhanced (different from instruction)")
                    } else {
                        print("     ⚠️  AudioScript same as instruction")
                    }
                } else {
                    print("   Step \(index + 1): ⚪ No audioScript (backward compatible)")
                }
            }
            
            print("   Enhanced steps: \(stepsWithAudioScript)/\(jamesRecipe.brewingSteps.count)")
            
        } catch {
            print("❌ Failed to decode recipe JSON: \(error)")
        }
    }
    
    func testAudioPathResolution() {
        // Simulate how AudioService resolves audio file paths
        let testCases = [
            (recipe: "James Hoffmann's Ultimate AeroPress", method: "AeroPress", fileName: "James_Hoffmann_Ultimate_AeroPress_step1.mp3"),
            (recipe: "Kaldi's Coffee - Single Serve", method: "V60", fileName: "single_serve_brewing_step_01.wav")
        ]
        
        for testCase in testCases {
            print("  Testing: \(testCase.recipe)")
            
            // Simulate AudioService path resolution logic
            let folderName = convertTitleToFolderName(testCase.recipe)
            let expectedPath = "Audio_Output/\(testCase.method)/\(folderName)/"
            
            print("    Expected folder: \(folderName)")
            print("    Expected path: \(expectedPath)")
            
            // Check if directory exists
            if FileManager.default.fileExists(atPath: expectedPath) {
                print("    ✅ Audio directory exists")
                
                // List available files
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: expectedPath)
                    let audioFiles = files.filter { $0.hasSuffix(".wav") || $0.hasSuffix(".mp3") }
                    print("    ✅ Found \(audioFiles.count) audio files")
                    
                    if audioFiles.count >= 5 { // Should have preparation + brewing steps
                        print("    ✅ Sufficient audio files for complete recipe")
                    } else {
                        print("    ⚠️  Fewer audio files than expected")
                    }
                } catch {
                    print("    ❌ Could not list directory contents: \(error)")
                }
            } else {
                print("    ❌ Audio directory not found")
            }
        }
    }
    
    func testBackwardCompatibility() {
        // Test that the system works with recipes that don't have audioScript
        print("  Testing recipes without audioScript fields...")
        
        // Create a sample brewing step without audioScript (backward compatibility)
        let legacyStep = BrewingStep(
            timeSeconds: 30,
            instruction: "Pour water slowly over coffee grounds",
            shortInstruction: "Pour water slowly",
            audioFileName: "step_01.wav",
            audioScript: nil
        )
        
        // Simulate AudioService logic
        let audioText = legacyStep.audioScript ?? legacyStep.instruction
        let isDetailed = legacyStep.audioScript != nil
        
        print("    Legacy step instruction: \"\(legacyStep.instruction)\"")
        print("    Audio text used: \"\(audioText)\"")
        print("    Is detailed script: \(isDetailed)")
        
        if audioText == legacyStep.instruction && !isDetailed {
            print("    ✅ Backward compatibility working correctly")
        } else {
            print("    ❌ Backward compatibility issue")
        }
        
        // Test with enhanced step
        let enhancedStep = BrewingStep(
            timeSeconds: 30,
            instruction: "Pour water slowly over coffee grounds",
            shortInstruction: "Pour water slowly",
            audioFileName: "step_01.wav",
            audioScript: "Now it's time to pour the water. Take your kettle and slowly pour the hot water over the coffee grounds in a circular motion. This should take about 30 seconds and you'll see the coffee start to bloom."
        )
        
        let enhancedAudioText = enhancedStep.audioScript ?? enhancedStep.instruction
        let enhancedIsDetailed = enhancedStep.audioScript != nil
        
        print("    Enhanced step audioScript: \"\(enhancedAudioText.prefix(50))...\"")
        print("    Is detailed script: \(enhancedIsDetailed)")
        
        if enhancedAudioText != enhancedStep.instruction && enhancedIsDetailed {
            print("    ✅ Enhanced recipe integration working correctly")
        } else {
            print("    ❌ Enhanced recipe integration issue")
        }
    }
    
    // Helper function matching AudioService logic
    private func convertTitleToFolderName(_ title: String) -> String {
        if title.contains("James Hoffmann") && title.contains("AeroPress") {
            return "James_Hoffmanns_Ultimate_AeroPress"
        } else if title.contains("Kaldi") && title.contains("Single Serve") {
            return "Kaldis_Coffee_-_Single_Serve"
        }
        
        // Default conversion
        return title.replacingOccurrences(of: "[^\\w\\s-]", with: "", options: .regularExpression)
                   .replacingOccurrences(of: " ", with: "_")
    }
}

// Simplified Recipe struct for testing
struct Recipe: Codable {
    let title: String
    let brewingMethod: String
    let brewingSteps: [BrewingStep]
    
    enum CodingKeys: String, CodingKey {
        case title
        case brewingMethod = "brewing_method"
        case brewingSteps = "brewing_steps"
    }
}

// Run the test
let test = AudioServiceIntegrationTest()
test.testEnhancedRecipeIntegration()
