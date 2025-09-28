#!/usr/bin/env swift
/*
Debug script to diagnose audio playback issues.
This will help identify why audio is not playing.
*/

import Foundation

// Simulate the exact AudioService logic
func debugAudioService() {
    print("🔍 DEBUGGING AUDIO SERVICE")
    print(String(repeating: "=", count: 50))
    
    // Test the 2021 World Champion recipe
    let recipeTitle = "2021 World AeroPress Champion - Tuomas Merikanto (Finland) - Inverted"
    let audioFileName = "2021_world_aeropress_brewing_step1.mp3"
    
    print("Recipe Title: \(recipeTitle)")
    print("Audio File Name: \(audioFileName)")
    print()
    
    // Simulate getBrewingMethod
    let brewingMethod = recipeTitle.contains("AeroPress") ? "AeroPress" : "Unknown"
    print("✅ Brewing Method: \(brewingMethod)")
    
    // Simulate convertTitleToFolderName
    let folderName = recipeTitle.contains("2021 World AeroPress Champion") ? 
        "2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted" : "Unknown"
    print("✅ Folder Name: \(folderName)")
    
    // Test different search strategies
    print("\n🔍 TESTING SEARCH STRATEGIES:")
    print(String(repeating: "-", count: 30))
    
    // Strategy 1: Direct bundle search
    print("1. Direct bundle search:")
    print("   Bundle.main.url(forResource: \"\(audioFileName)\", withExtension: nil)")
    print("   ❓ This would look in bundle root")
    
    // Strategy 2: Subdirectory search
    print("\n2. Subdirectory search:")
    let subdirectory = "Audio/\(brewingMethod)/World_Champions/\(folderName)"
    print("   Bundle.main.url(forResource: \"\(audioFileName)\", withExtension: nil, subdirectory: \"\(subdirectory)\")")
    print("   ❓ This should find the file")
    
    // Strategy 3: Alternative subdirectory
    print("\n3. Alternative subdirectory:")
    let altSubdirectory = "Audio/\(brewingMethod)/\(folderName)"
    print("   Bundle.main.url(forResource: \"\(audioFileName)\", withExtension: nil, subdirectory: \"\(altSubdirectory)\")")
    print("   ❓ This might also work")
    
    print("\n🎯 EXPECTED RESULT:")
    print("The AudioService should find the file using Strategy 2:")
    print("   subdirectory: \"\(subdirectory)\"")
    
    print("\n🔧 DEBUGGING STEPS:")
    print("1. Check if Audio folder is included in Xcode project")
    print("2. Verify files are in the app bundle")
    print("3. Check debug logs in Xcode console")
    print("4. Test with a simple audio file first")
    
    print("\n📋 COMMON ISSUES:")
    print("• Audio folder not added to Xcode project")
    print("• Files not included in app bundle")
    print("• Incorrect file paths in AudioService")
    print("• Audio session not properly configured")
    print("• File permissions or format issues")
}

// Test file existence
func testFileExistence() {
    print("\n📁 TESTING FILE EXISTENCE:")
    print(String(repeating: "-", count: 30))
    
    let basePath = "/Users/home/Documents/Programando/PerfectBrew/PerfectBrew/Resources/Audio"
    let fileManager = FileManager.default
    
    let testPaths = [
        "\(basePath)/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted/2021_world_aeropress_brewing_step1.mp3",
        "\(basePath)/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted/2021_world_aeropress_brewing_step2.mp3"
    ]
    
    for path in testPaths {
        let fileName = URL(fileURLWithPath: path).lastPathComponent
        if fileManager.fileExists(atPath: path) {
            print("✅ \(fileName) - EXISTS")
        } else {
            print("❌ \(fileName) - NOT FOUND")
        }
    }
}

// Main execution
debugAudioService()
testFileExistence()

print("\n" + String(repeating: "=", count: 50))
print("🎯 NEXT STEPS:")
print("1. Open Xcode and check if Audio folder is blue (folder reference)")
print("2. Build and run the app")
print("3. Check Xcode console for debug messages")
print("4. Test audio playback in the 2021 World Champion recipe")
print("5. If still not working, check AudioService debug logs")
