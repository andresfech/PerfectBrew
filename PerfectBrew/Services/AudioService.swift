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
        print("DEBUG: playAudio called for recipe: '\(recipeTitle)'")
        print("DEBUG: step.audioFileName: \(step.audioFileName ?? "nil")")
        
        guard let audioFileName = step.audioFileName else {
            print("DEBUG: No audio file specified for step")
            return
        }
        
        // Stop any currently playing audio
        stopAudio()
        
        // Construct the audio file path
        let audioPath = getAudioPath(for: audioFileName, recipeTitle: recipeTitle)
        print("DEBUG: Audio path: \(audioPath)")
        
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
    
    func playNotesAudio(for recipeTitle: String) {
        print("DEBUG: playNotesAudio called for recipe: '\(recipeTitle)'")
        
        // Stop any currently playing audio
        stopAudio()
        
        // Get the correct notes audio filename based on recipe title
        let notesFileName = getNotesFileName(for: recipeTitle)
        print("DEBUG: Notes filename: \(notesFileName)")
        
        // Construct the audio file path for notes
        let audioPath = getAudioPath(for: notesFileName, recipeTitle: recipeTitle)
        print("DEBUG: Notes audio path: \(audioPath)")
        
        do {
            // Load and play the audio file
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentAudioFile = notesFileName
            
            print("DEBUG: Playing notes audio for recipe: \(recipeTitle)")
        } catch {
            print("DEBUG: Failed to play notes audio for recipe \(recipeTitle): \(error)")
            isPlaying = false
            currentAudioFile = nil
        }
    }
    
    private func getNotesFileName(for recipeTitle: String) -> String {
        // Convert recipe title to the correct notes filename
        
        // AeroPress notes
        if recipeTitle.contains("Tim Wendelboe") && recipeTitle.contains("AeroPress") {
            return "Tim_W_classic_aeropress_notes.mp3"
        } else if recipeTitle.contains("James Hoffmann") && recipeTitle.contains("AeroPress") {
            return "James_Hoffmann_Ultimate_AeroPress_notes.mp3"
        } else if recipeTitle.contains("2024 World AeroPress Champion") {
            return "2024_world_aeropress_notes.mp3"
        } else if recipeTitle.contains("2023 World AeroPress Champion") {
            return "2023_world_aeropress_notes.mp3"
        } else if recipeTitle.contains("2022 World AeroPress Champion") {
            return "2022_world_aeropress_notes.mp3"
        } else if recipeTitle.contains("2021 World AeroPress Champion") {
            return "2021_world_aeropress_notes.mp3"
        } else if recipeTitle.contains("Championship Concentrate") {
            return "Championship_Concentrate_notes.mp3"
        }
        
        // V60 notes
        else if recipeTitle.contains("Kaldi's Coffee - Single Serve") {
            return "single_serve_notes.wav"
        } else if recipeTitle.contains("Kaldi's Coffee - Two People") {
            return "two_people_notes.wav"
        } else if recipeTitle.contains("Kaldi's Coffee - Three People") {
            return "three_people_notes.wav"
        } else if recipeTitle.contains("James Hoffmann V60") {
            return "james_hoffmann_v60_notes.wav"
        } else if recipeTitle.contains("Scott Rao V60") {
            return "scott_rao_v60_notes.wav"
        } else if recipeTitle.contains("Quick Morning V60") {
            return "quick_morning_v60_notes.wav"
        }
        
        // French Press notes
        else if recipeTitle.contains("James Hoffmann") && recipeTitle.contains("French Press") {
            return "james_hoffmann_french_press_notes.wav"
        } else if recipeTitle.contains("Tim Wendelboe") && recipeTitle.contains("French Press") {
            return "tim_wendelboe_french_press_notes.wav"
        } else if recipeTitle.contains("Scott Rao") && recipeTitle.contains("French Press") {
            return "scott_rao_french_press_notes.wav"
        }
        
        // Default fallback
        return "notes.wav"
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
        let method = getBrewingMethod(recipeTitle)
        
        // Try to find the audio file with the exact name (including extension)
        let audioPath = Bundle.main.url(forResource: "Audio/\(method)/\(folderName)/\(fileName)", withExtension: nil)
        
        // If not found, try to find it by name without extension
        if audioPath == nil {
            let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
            let fileExtension = (fileName as NSString).pathExtension
            
            if fileExtension.isEmpty {
                // Try common audio extensions
                for ext in ["mp3", "m4a", "wav", "aac"] {
                    if let path = Bundle.main.url(forResource: "Audio/\(method)/\(folderName)/\(fileNameWithoutExtension)", withExtension: ext) {
                        return path
                    }
                }
            } else {
                // Try with the specified extension
                if let path = Bundle.main.url(forResource: "Audio/\(method)/\(folderName)/\(fileNameWithoutExtension)", withExtension: fileExtension) {
                    return path
                }
            }
        }
        
        // Fallback to default path if specific path not found
        return audioPath ?? Bundle.main.url(forResource: fileName, withExtension: nil) ?? URL(fileURLWithPath: "")
    }
    
    private func getBrewingMethod(_ title: String) -> String {
        // Determine brewing method based on recipe title
        if title.contains("AeroPress") || title.contains("aeropress") {
            return "AeroPress"
        } else if title.contains("V60") || title.contains("v60") {
            return "V60"
        } else if title.contains("French Press") || title.contains("french press") {
            return "FrenchPress"
        }
        
        // Default to AeroPress for backward compatibility
        return "AeroPress"
    }
    
    private func convertTitleToFolderName(_ title: String) -> String {
        // Convert recipe title to folder name format
        
        // AeroPress recipes
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
        } else if title.contains("Tim W. Classic AeroPress") {
            return "Tim_W_Classic"
        } else if title.contains("James Hoffmann's Ultimate AeroPress") {
            return "James_Hoffmann_Ultimate_AeroPress"
        }
        
        // V60 recipes
        else if title.contains("Kaldi's Coffee - Single Serve") {
            return "Kaldi_Coffee_Single_Serve"
        } else if title.contains("Kaldi's Coffee - Two People") {
            return "Kaldi_Coffee_Two_People"
        } else if title.contains("Kaldi's Coffee - Three People") {
            return "Kaldi_Coffee_Three_People"
        } else if title.contains("James Hoffmann V60 - Single Serve") {
            return "James_Hoffmann_V60_Single_Serve"
        } else if title.contains("James Hoffmann V60 - Two People") {
            return "James_Hoffmann_V60_Two_People"
        } else if title.contains("James Hoffmann V60 - Three People") {
            return "James_Hoffmann_V60_Three_People"
        } else if title.contains("James Hoffmann V60 - Four People") {
            return "James_Hoffmann_V60_Four_People"
        } else if title.contains("Scott Rao V60 - Two People") {
            return "Scott_Rao_V60_Two_People"
        } else if title.contains("Scott Rao V60 - Three People") {
            return "Scott_Rao_V60_Three_People"
        } else if title.contains("Scott Rao V60 - Four People") {
            return "Scott_Rao_V60_Four_People"
        } else if title.contains("Quick Morning V60") {
            return "Quick_Morning_V60"
        }
        
        // French Press recipes
        else if title.contains("James Hoffmann's French Press Method") {
            return "James_Hoffmann_French_Press_Method"
        } else if title.contains("Tim Wendelboe French Press Method") {
            return "Tim_Wendelboe_French_Press_Method"
        } else if title.contains("Scott Rao French Press Method") {
            return "Scott_Rao_French_Press_Method"
        } else if title.contains("Blue Bottle French Press Method") {
            return "Blue_Bottle_French_Press_Method"
        } else if title.contains("Intelligentsia French Press Method") {
            return "Intelligentsia_French_Press_Method"
        } else if title.contains("Stumptown French Press Method") {
            return "Stumptown_French_Press_Method"
        } else if title.contains("Counter Culture French Press Method") {
            return "Counter_Culture_French_Press_Method"
        } else if title.contains("Verve French Press Method") {
            return "Verve_French_Press_Method"
        } else if title.contains("Four Barrel French Press Method") {
            return "Four_Barrel_French_Press_Method"
        }
        
        // Default fallback
        return "Standard_1_Person"
    }
    
    func hasAudio(for step: BrewingStep) -> Bool {
        let hasAudio = step.audioFileName != nil
        print("DEBUG: hasAudio check - step.audioFileName: \(step.audioFileName ?? "nil"), result: \(hasAudio)")
        return hasAudio
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
