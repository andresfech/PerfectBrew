import Foundation
import AVFoundation
import Combine

class AudioService: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentAudioFile: String?
    
    private var audioPlayer: AVAudioPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("DEBUG: Failed to setup audio session: \(error)")
        }
    }
    
    func playAudio(for step: BrewingStep, recipeTitle: String) {
        guard let audioFileName = step.audioFileName else {
            print("DEBUG: No audio file specified for step")
            return
        }
        
        // Stop any currently playing audio
        stopAudio()
        
        // Construct the audio file path
        let audioPath = getAudioPath(for: audioFileName, recipeTitle: recipeTitle)
        
        do {
            // Load and play the audio file
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentAudioFile = audioFileName
            
            print("DEBUG: Playing audio: \(audioFileName)")
        } catch {
            print("DEBUG: Failed to play audio \(audioFileName): \(error)")
            isPlaying = false
            currentAudioFile = nil
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentAudioFile = nil
    }
    
    private func getAudioPath(for fileName: String, recipeTitle: String) -> URL {
        // Convert recipe title to folder name format
        let folderName = convertTitleToFolderName(recipeTitle)
        
        // Try to find the audio file with the exact name (including extension)
        let audioPath = Bundle.main.url(forResource: "Audio/AeroPress/\(folderName)/\(fileName)", withExtension: nil)
        
        // If not found, try to find it by name without extension
        if audioPath == nil {
            let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
            let fileExtension = (fileName as NSString).pathExtension
            
            if fileExtension.isEmpty {
                // Try common audio extensions
                for ext in ["mp3", "m4a", "wav", "aac"] {
                    if let path = Bundle.main.url(forResource: "Audio/AeroPress/\(folderName)/\(fileNameWithoutExtension)", withExtension: ext) {
                        return path
                    }
                }
            } else {
                // Try with the specified extension
                if let path = Bundle.main.url(forResource: "Audio/AeroPress/\(folderName)/\(fileNameWithoutExtension)", withExtension: fileExtension) {
                    return path
                }
            }
        }
        
        // Fallback to default path if specific path not found
        return audioPath ?? Bundle.main.url(forResource: fileName, withExtension: nil) ?? URL(fileURLWithPath: "")
    }
    
    private func convertTitleToFolderName(_ title: String) -> String {
        // Convert recipe title to folder name format
        // Example: "2024 World AeroPress Champion - George Stanica (Romania) - Inverted" -> "2024_World_Champion"
        
        if title.contains("2024 World AeroPress Champion") {
            return "2024_World_Champion"
        } else if title.contains("2023 World AeroPress Champion") {
            return "2023_World_Champion"
        } else if title.contains("2022 World AeroPress Champion") {
            return "2022_World_Champion"
        } else if title.contains("2021 World AeroPress Champion") {
            return "2021_World_Champion"
        } else if title.contains("Standard") && title.contains("1") {
            return "Standard_1_Person"
        } else if title.contains("Standard") && title.contains("2") {
            return "Standard_2_Person"
        } else if title.contains("Inverted") && title.contains("1") {
            return "Inverted_1_Person"
        } else if title.contains("Inverted") && title.contains("2") {
            return "Inverted_2_Person"
        } else if title.contains("Championship Concentrate") {
            return "Championship_Concentrate"
        }
        
        // Default fallback
        return "Standard_1_Person"
    }
    
    func hasAudio(for step: BrewingStep) -> Bool {
        return step.audioFileName != nil
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentAudioFile = nil
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("DEBUG: Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentAudioFile = nil
        }
    }
}
