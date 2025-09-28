#!/usr/bin/env swift
/*
Test script to verify AudioService integration logic.
This simulates the exact logic used in the AudioService.
*/

import Foundation

// Simulate the AudioService logic exactly
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
    
    // First, try to find the audio file directly in bundle root (for backward compatibility)
    // This would be: Bundle.main.url(forResource: fileName, withExtension: nil)
    print("   Trying bundle root search...")
    
    // If not found, try to find it by name without extension in bundle root
    let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
    let fileExtension = (fileName as NSString).pathExtension
    
    print("   File name without extension: \(fileNameWithoutExtension)")
    print("   File extension: \(fileExtension)")
    
    // If not found in bundle root, try to find it in the Audio folder structure
    let brewingMethod = getBrewingMethod(recipeTitle)
    let folderName = convertTitleToFolderName(recipeTitle)
    
    print("   Brewing method: \(brewingMethod)")
    print("   Folder name: \(folderName)")
    
    // Try different subdirectory approaches
    let subdirectories = [
        "Audio/\(brewingMethod)/\(folderName)",
        "Audio/\(brewingMethod)/World_Champions/\(folderName)",
        "Audio/\(brewingMethod)/World_Champions/\(folderName)"
    ]
    
    print("\n   Trying subdirectory searches:")
    for (index, subdirectory) in subdirectories.enumerated() {
        print("   \(index + 1). Subdirectory: '\(subdirectory)'")
        
        // Try with full filename
        let fullPath1 = "\(subdirectory)/\(fileName)"
        print("      - Full filename: \(fullPath1)")
        
        // Try with filename without extension
        let extensionToUse = fileExtension.isEmpty ? "mp3" : fileExtension
        let fullPath2 = "\(subdirectory)/\(fileNameWithoutExtension).\(extensionToUse)"
        print("      - Without extension: \(fullPath2)")
    }
    
    // The correct path should be:
    let correctPath = "Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted/\(fileName)"
    print("\n   ✅ Expected correct path: \(correctPath)")
    
    return correctPath
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

print("🎵 Testing AudioService Integration Logic")
print(String(repeating: "=", count: 60))
print("Recipe: \(recipeTitle)")
print(String(repeating: "=", count: 60))

for audioFile in audioFiles {
    print("\n" + String(repeating: "-", count: 50))
    let result = getAudioPath(for: audioFile, recipeTitle: recipeTitle)
    print("   Result: \(result)")
}

print("\n" + String(repeating: "=", count: 60))
print("🎯 SUMMARY:")
print("The AudioService should find files using:")
print("   Bundle.main.url(forResource: \"\(audioFiles[0])\", withExtension: nil, subdirectory: \"Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted\")")
print("\nThis should work if the Audio folder is properly included in the Xcode project.")