#!/usr/bin/env swift
/*
Test script to verify audio integration for 2021 World Champion recipe.
This script simulates the audio path resolution logic.
*/

import Foundation

// Simulate the AudioService logic
func getBrewingMethod(_ title: String) -> String {
    if title.contains("AeroPress") || title.contains("aeropress") {
        return "AeroPress"
    } else if title.contains("V60") || title.contains("v60") {
        return "V60"
    } else if title.contains("French Press") || title.contains("french press") {
        return "FrenchPress"
    }
    return "AeroPress"
}

func convertTitleToFolderName(_ title: String) -> String {
    if title.contains("2021 World AeroPress Champion") {
        return "2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted"
    }
    return "Unknown"
}

func getAudioPath(for fileName: String, recipeTitle: String) -> String {
    print("🔍 Looking for audio file: \(fileName) for recipe: \(recipeTitle)")
    
    let brewingMethod = getBrewingMethod(recipeTitle)
    let folderName = convertTitleToFolderName(recipeTitle)
    
    print("   Brewing method: \(brewingMethod)")
    print("   Folder name: \(folderName)")
    
    // Construct possible paths
    let possiblePaths = [
        "Audio/\(brewingMethod)/\(folderName)/\(fileName)",
        "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(fileName)",
        "Audio/\(brewingMethod)/\(folderName)/\(fileName.replacingOccurrences(of: ".mp3", with: "")).mp3",
        "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(fileName.replacingOccurrences(of: ".mp3", with: "")).mp3"
    ]
    
    print("\n📁 Possible paths to check:")
    for (index, path) in possiblePaths.enumerated() {
        print("   \(index + 1). \(path)")
    }
    
    // Check if files exist in the actual file system
    let basePath = "/Users/home/Documents/Programando/PerfectBrew/PerfectBrew/Resources"
    let fileManager = FileManager.default
    
    for path in possiblePaths {
        let fullPath = "\(basePath)/\(path)"
        if fileManager.fileExists(atPath: fullPath) {
            print("✅ FOUND: \(path)")
            return fullPath
        } else {
            print("❌ NOT FOUND: \(path)")
        }
    }
    
    print("❌ Audio file not found anywhere")
    return ""
}

// Test the 2021 World Champion recipe
let recipeTitle = "2021 World AeroPress Champion - Tuomas Merikanto (Finland) - Inverted"
let audioFiles = [
    "2021_world_aeropress_brewing_step1.mp3",
    "2021_world_aeropress_brewing_step2.mp3",
    "2021_world_aeropress_brewing_step3.mp3",
    "2021_world_aeropress_brewing_step4.mp3",
    "2021_world_aeropress_brewing_step5.mp3",
    "2021_world_aeropress_brewing_step6.mp3",
    "2021_world_aeropress_brewing_step7.mp3",
    "2021_world_aeropress_brewing_step8.mp3"
]

print("🎵 Testing Audio Integration for 2021 World Champion Recipe")
print(String(repeating: "=", count: 60))
print("Recipe: \(recipeTitle)")
print(String(repeating: "=", count: 60))

var foundCount = 0
for audioFile in audioFiles {
    print("\n" + String(repeating: "=", count: 40))
    let result = getAudioPath(for: audioFile, recipeTitle: recipeTitle)
    if !result.isEmpty {
        foundCount += 1
    }
}

print("\n" + String(repeating: "=", count: 60))
print("📊 RESULTS:")
print("   Total audio files: \(audioFiles.count)")
print("   Found: \(foundCount)")
print("   Missing: \(audioFiles.count - foundCount)")

if foundCount == audioFiles.count {
    print("✅ ALL AUDIO FILES FOUND! Integration should work correctly.")
} else {
    print("❌ Some audio files are missing. Check file paths and Xcode project setup.")
}

print("\n📋 NEXT STEPS:")
print("1. Add Audio folder to Xcode project as folder reference")
print("2. Build and run the app")
print("3. Test audio playback in the 2021 World Champion recipe")