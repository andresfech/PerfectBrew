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
    
    func playNotesAudio(for recipeTitle: String, audioFileName: String? = nil) {
        print("DEBUG: playNotesAudio called for recipe: '\(recipeTitle)'")
        
        // Stop any currently playing audio
        stopAudio()
        
        // Get the correct notes audio filename: use provided one or fallback to mapping
        let notesFileName = audioFileName ?? getNotesFileName(for: recipeTitle)
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
            return "tim_wendelboe_intro.m4a"
        } else if recipeTitle.contains("James Hoffmann") && recipeTitle.contains("AeroPress") {
            // Use dedicated intro file generated for James Hoffmann AeroPress
            return "james_hoffmann_aeropress_intro.m4a"
        } else if recipeTitle.contains("2024 World AeroPress Champion") {
            // Use dedicated intro file generated for George Stanica 2024
            return "george_2024_intro.m4a"
        } else if recipeTitle.contains("2023 World AeroPress Champion") {
            // Use dedicated intro file generated for Tay Wipvasutt 2023
            return "tay_2023_intro.m4a"
        } else if recipeTitle.contains("2022 World AeroPress Champion") {
            // Use dedicated intro file generated for Jibbi Little 2022
            return "jibbi_2022_intro.m4a"
        } else if recipeTitle.contains("2021 World AeroPress Champion") {
            // Use dedicated intro file generated for Tuomas Merikanto 2021
            return "tuomas_2021_intro.m4a"
        } else if recipeTitle.contains("Championship Concentrate") {
            return "Championship_Concentrate_notes.mp3"
        }
        
        // V60 notes
        else if recipeTitle.contains("Kaldi's Coffee - Single Serve") {
            // Use dedicated intro file generated for Kaldis Coffee Single Serve
            return "kaldis_single_intro.m4a"
        } else if recipeTitle.contains("Kaldi's Coffee - Two People") {
            return "two_people_notes.wav"
        } else if recipeTitle.contains("Kaldi's Coffee - Three People") {
            return "three_people_notes.wav"
        } else if recipeTitle.contains("James Hoffmann V60") {
            // Use dedicated intro file generated for James Hoffmann
            return "hoffmann_intro.m4a"
        } else if recipeTitle.contains("Scott Rao V60") {
            // Prefer per-recipe intro file to avoid generic notes.wav collisions
            return "scott_rao_intro.m4a"
        } else if recipeTitle.contains("Tetsu Kasuya") {
            // Use dedicated intro file generated for Tetsu
            return "tetsu_intro.m4a"
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
        print("DEBUG: Looking for audio file: \(fileName) for recipe: \(recipeTitle)")
        
        // Prefer structured Audio folder paths first to avoid stale bundle-root files
        let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
        let fileExtension = (fileName as NSString).pathExtension
        
        // Try to find it in the Audio folder structure
        let brewingMethod = getBrewingMethod(recipeTitle)
        let folderName = convertTitleToFolderName(recipeTitle)
        
        // Try different subdirectory approaches
        let subdirectories = [
            "Audio/\(brewingMethod)/\(folderName)",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)",
            "Audio/\(brewingMethod)/\(folderName)/\(folderName)_AeroPress",
            "Audio/\(brewingMethod)/\(folderName)/\(folderName)_Classic_AeroPress",
            "Audio/\(brewingMethod)/\(folderName)/\(folderName)s_Ultimate_AeroPress",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(folderName)_AeroPress",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(folderName)_Classic_AeroPress",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(folderName)s_Ultimate_AeroPress"
        ]
        
        for subdirectory in subdirectories {
            // Try with full filename
            if let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: subdirectory) {
                print("DEBUG: Found audio file in subdirectory '\(subdirectory)': \(url)")
                return url
            }
            
            // Try with filename without extension
            if let url = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension.isEmpty ? "mp3" : fileExtension, subdirectory: subdirectory) {
                print("DEBUG: Found audio file in subdirectory '\(subdirectory)' with extension: \(url)")
                return url
            }
        }
        
        // Try to find by searching in the Audio folder
        if let audioFolderURL = Bundle.main.url(forResource: "Audio", withExtension: nil) {
            let audioPath = audioFolderURL.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: audioPath.path) {
                print("DEBUG: Found audio file in Audio folder: \(audioPath)")
                return audioPath
            }
        }
        
        // Fallbacks: bundle root as last resort
        if let path = Bundle.main.url(forResource: fileName, withExtension: nil) {
            print("DEBUG: Found audio file in bundle root (fallback): \(path)")
            return path
        }
        if !fileExtension.isEmpty {
            if let path = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension) {
                print("DEBUG: Found audio file with specified extension in bundle root (fallback): \(path)")
                return path
            }
        } else {
            for ext in ["mp3", "m4a", "wav", "aac"] {
                if let path = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: ext) {
                    print("DEBUG: Found audio file with extension \(ext) in bundle root (fallback): \(path)")
                    return path
                }
            }
        }

        print("DEBUG: Audio file not found: \(fileName) anywhere in bundle")
        return URL(fileURLWithPath: "")
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
            return "2024_George_Stanica_Romania"
        } else if title.contains("2023 World AeroPress Champion") {
            return "2023_Tay_Wipvasutt_Thailand"
        } else if title.contains("2022 World AeroPress Champion") {
            return "2022_Jibbi_Little_Australia"
        } else if title.contains("2021 World AeroPress Champion") {
            return "2021_Tuomas_Merikanto_Finland"
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
            return "Tim_Wendelboe"
        } else if title.contains("James Hoffmann's Ultimate AeroPress") {
            return "James_Hoffmann"
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
        } else if title.contains("Tetsu Kasuya") {
            // Map all Tetsu Kasuya V60 variants to a single folder
            return "Tetsu_Kasuya"
        } else if title.contains("Scott Rao V60 Method (Single Serve - Detailed)") {
            return "Scott_Rao_V60_Method_Single_Serve_Detailed"
        } else if title.contains("Scott Rao V60 Method (Single Serve)") {
            return "Scott_Rao_V60_Method_Single_Serve_Detailed"
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
