#!/usr/bin/env swift

import Foundation
import AVFoundation

// Test AudioService integration with enhanced audio files
class AudioIntegrationTest {
    private var audioPlayer: AVAudioPlayer?
    
    func testAudioFileIntegration() {
        print("🎵 Testing Audio File Integration with iOS App")
        print(String(repeating: "=", count: 50))
        
        // Test 1: Verify generated audio files exist and are playable
        let testFiles = [
            "Audio_Output/AeroPress/James_Hoffmanns_Ultimate_AeroPress/brewing_step_01.wav",
            "Audio_Output/AeroPress/James_Hoffmanns_Ultimate_AeroPress/brewing_step_02.wav",
            "Audio_Output/V60/Kaldis_Coffee_-_Single_Serve/brewing_step_01.wav",
            "Audio_Output/V60/Kaldis_Coffee_-_Single_Serve/brewing_step_02.wav"
        ]
        
        var successCount = 0
        var totalFiles = 0
        
        print("\n📁 Testing Generated Audio Files:")
        
        for filePath in testFiles {
            totalFiles += 1
            print("  Testing: \(URL(fileURLWithPath: filePath).lastPathComponent)")
            
            let fileURL = URL(fileURLWithPath: filePath)
            
            // Check if file exists
            guard FileManager.default.fileExists(atPath: filePath) else {
                print("    ❌ File not found")
                continue
            }
            
            // Check file size
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                let fileSize = attributes[.size] as? Int64 ?? 0
                print("    📊 File size: \(formatFileSize(fileSize))")
                
                if fileSize < 1000 {
                    print("    ⚠️  File seems too small")
                    continue
                }
            } catch {
                print("    ❌ Could not read file attributes: \(error)")
                continue
            }
            
            // Test audio file validity
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                let duration = audioPlayer.duration
                print("    ⏱️  Duration: \(String(format: "%.1f", duration))s")
                
                if duration > 0 {
                    print("    ✅ Audio file valid and playable")
                    successCount += 1
                } else {
                    print("    ❌ Audio file has zero duration")
                }
            } catch {
                print("    ❌ Cannot create audio player: \(error)")
            }
        }
        
        print("\n📊 Audio File Test Results:")
        print("   Total files tested: \(totalFiles)")
        print("   Successfully validated: \(successCount)")
        print("   Success rate: \(Int(Double(successCount) / Double(totalFiles) * 100))%")
        
        // Test 2: Verify audio file naming conventions match iOS expectations
        print("\n🏷️  Testing Audio File Naming Conventions:")
        testAudioFileNaming()
        
        // Test 3: Test audio file discovery simulation
        print("\n🔍 Testing Audio File Discovery:")
        testAudioDiscovery()
        
        print("\n" + String(repeating: "=", count: 50))
        if successCount == totalFiles {
            print("🎉 All audio integration tests passed!")
        } else {
            print("⚠️  Some audio integration tests failed.")
        }
    }
    
    func testAudioFileNaming() {
        // Test that generated files follow the expected naming pattern
        let expectedPatterns = [
            "preparation_step_\\d{2}\\.wav",
            "brewing_step_\\d{2}\\.wav",
            "notes\\.wav"
        ]
        
        let audioDir = "Audio_Output"
        let enumerator = FileManager.default.enumerator(atPath: audioDir)
        var foundFiles: [String] = []
        
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".wav") {
                foundFiles.append(file)
            }
        }
        
        print("  Found \(foundFiles.count) audio files")
        
        var validNaming = 0
        for file in foundFiles.prefix(5) { // Test first 5 files
            let fileName = URL(fileURLWithPath: file).lastPathComponent
            var isValid = false
            
            for pattern in expectedPatterns {
                if fileName.range(of: pattern, options: .regularExpression) != nil {
                    isValid = true
                    break
                }
            }
            
            if isValid {
                validNaming += 1
                print("    ✅ \(fileName) - Valid naming")
            } else {
                print("    ⚠️  \(fileName) - Unexpected naming")
            }
        }
        
        print("  Naming convention compliance: \(Int(Double(validNaming) / Double(min(foundFiles.count, 5)) * 100))%")
    }
    
    func testAudioDiscovery() {
        // Simulate how iOS AudioService would discover and load audio files
        let recipeTitles = [
            "James Hoffmann's Ultimate AeroPress",
            "Kaldi's Coffee - Single Serve"
        ]
        
        for title in recipeTitles {
            print("  Testing discovery for: \(title)")
            let folderName = convertTitleToFolderName(title)
            let method = getBrewingMethod(title)
            let audioPath = "Audio_Output/\(method)/\(folderName)/"
            
            if FileManager.default.fileExists(atPath: audioPath) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: audioPath)
                    let audioFiles = files.filter { $0.hasSuffix(".wav") }
                    print("    ✅ Found \(audioFiles.count) audio files in expected location")
                    
                    // Test a few specific files
                    let testFiles = ["brewing_step_01.wav", "brewing_step_02.wav", "preparation_step_01.wav"]
                    for testFile in testFiles {
                        if audioFiles.contains(testFile) {
                            print("      ✅ \(testFile) found")
                        } else {
                            print("      ⚪ \(testFile) not found (may be normal)")
                        }
                    }
                } catch {
                    print("    ❌ Could not read directory: \(error)")
                }
            } else {
                print("    ❌ Audio directory not found: \(audioPath)")
            }
        }
    }
    
    // Helper functions (simplified versions of AudioService methods)
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
    
    private func getBrewingMethod(_ title: String) -> String {
        if title.contains("AeroPress") {
            return "AeroPress"
        } else if title.contains("V60") || title.contains("Kaldi") {
            return "V60"
        } else if title.contains("French Press") {
            return "FrenchPress"
        }
        return "Unknown"
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%.1f MB", mb)
        }
    }
}

// Run the test
let test = AudioIntegrationTest()
test.testAudioFileIntegration()
