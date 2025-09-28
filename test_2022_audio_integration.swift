#!/usr/bin/env swift

import Foundation
import AVFoundation

// Test script to verify 2022 World Champion audio integration
print("🎵 Testing 2022 World Champion Audio Integration")
print(String(repeating: "=", count: 60))

// Test 1: Check if audio files exist
print("\n1. Checking audio file existence...")
let audioFiles = [
    "2022_jibbi_little_aeropress_step1_pour_stir.m4a",
    "2022_jibbi_little_aeropress_step2_cap_air.m4a", 
    "2022_jibbi_little_aeropress_step3_flip_press.m4a",
    "2022_jibbi_little_aeropress_step4_complete_press.m4a",
    "2022_jibbi_little_aeropress_step5_bypass_water.m4a",
    "2022_jibbi_little_aeropress_step6_ice_balls.m4a"
]

let audioDir = "/Users/home/Documents/Programando/PerfectBrew/PerfectBrew/Resources/Audio/AeroPress/World_Champions/2022_Jibbi_Little_Australia/2022_World_AeroPress_Champion_Jibbi_Little_Austral/"

var allFilesExist = true
for audioFile in audioFiles {
    let filePath = audioDir + audioFile
    let exists = FileManager.default.fileExists(atPath: filePath)
    print("   \(exists ? "✅" : "❌") \(audioFile) - \(exists ? "Found" : "Missing")")
    if !exists { allFilesExist = false }
}

print("\n   Overall: \(allFilesExist ? "✅ All files exist" : "❌ Some files missing")")

// Test 2: Check file sizes
print("\n2. Checking file sizes...")
for audioFile in audioFiles {
    let filePath = audioDir + audioFile
    if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) {
        let size = attributes[.size] as? Int64 ?? 0
        let sizeKB = size / 1024
        print("   📁 \(audioFile): \(sizeKB) KB")
    } else {
        print("   ❌ \(audioFile): Could not read file")
    }
}

// Test 3: Test AudioService path resolution logic
print("\n3. Testing AudioService path resolution...")

func convertTitleToFolderName(_ title: String) -> String {
    if title.contains("2022 World AeroPress Champion") {
        return "2022_Jibbi_Little_Australia"
    }
    return "Unknown"
}

func getAudioPath(for fileName: String, recipeTitle: String) -> String {
    let brewingMethod = "AeroPress"
    let folderName = convertTitleToFolderName(recipeTitle)
    let subdirectory = "Audio/\(brewingMethod)/World_Champions/\(folderName)/2022_World_AeroPress_Champion_Jibbi_Little_Austral/"
    
    // Simulate Bundle.main.url resolution
    let bundlePath = "/Users/home/Documents/Programando/PerfectBrew/PerfectBrew/Resources/"
    let fullPath = bundlePath + subdirectory + fileName
    
    return fullPath
}

let recipeTitle = "2022 World AeroPress Champion - Jibbi Little (Australia) - Inverted"
let testFileName = "2022_jibbi_little_aeropress_step1_pour_stir.m4a"
let resolvedPath = getAudioPath(for: testFileName, recipeTitle: recipeTitle)

print("   Recipe Title: \(recipeTitle)")
print("   Folder Name: \(convertTitleToFolderName(recipeTitle))")
print("   Resolved Path: \(resolvedPath)")
print("   File Exists: \(FileManager.default.fileExists(atPath: resolvedPath) ? "✅ Yes" : "❌ No")")

// Test 4: Test AVAudioPlayer compatibility
print("\n4. Testing AVAudioPlayer compatibility...")
let testFile = audioDir + audioFiles[0]
if FileManager.default.fileExists(atPath: testFile) {
    do {
        let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: testFile))
        print("   ✅ AVAudioPlayer can load the file")
        print("   📊 Duration: \(String(format: "%.2f", audioPlayer.duration)) seconds")
        print("   📊 Sample Rate: \(audioPlayer.deviceCurrentTime) Hz")
    } catch {
        print("   ❌ AVAudioPlayer error: \(error)")
    }
} else {
    print("   ❌ Test file not found")
}

// Test 5: Recipe JSON validation
print("\n5. Testing recipe JSON structure...")
let recipePath = "/Users/home/Documents/Programando/PerfectBrew/PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2022_Jibbi_Little_Australia/AeroPress_2022_Jibbi_Little_single_serve.json"

if let data = FileManager.default.contents(atPath: recipePath),
   let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
   let recipe = json.first,
   let brewingSteps = recipe["brewing_steps"] as? [[String: Any]] {
    
    print("   ✅ Recipe JSON loaded successfully")
    print("   📊 Number of brewing steps: \(brewingSteps.count)")
    
    for (index, step) in brewingSteps.enumerated() {
        if let audioFileName = step["audio_file_name"] as? String {
            print("   Step \(index + 1): \(audioFileName)")
        }
    }
} else {
    print("   ❌ Failed to load recipe JSON")
}

print("\n" + String(repeating: "=", count: 60))
print("🎉 2022 World Champion Audio Integration Test Complete!")
print("\nNext steps:")
print("1. Build and run the app in Xcode")
print("2. Select the 2022 World Champion recipe")
print("3. Start brewing and verify audio plays for each step")
print("4. Check console logs for any audio path resolution issues")
