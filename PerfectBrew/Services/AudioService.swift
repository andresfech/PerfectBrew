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
        
        // AEC-13: Use localized audio file name (Spanish if available, else English)
        let currentLang = LocalizationManager.shared.currentLanguage
        print("DEBUG: Current language: \(currentLang.rawValue)")
        print("DEBUG: step.audioFileName: \(step.audioFileName ?? "nil")")
        print("DEBUG: step.audioFileNameEs: \(step.audioFileNameEs ?? "nil")")
        
        // Try localized version first, then fallback to English
        let audioFileName = step.localizedAudioFileName
        
        guard let fileName = audioFileName else {
            print("DEBUG: No audio file specified for step")
            return
        }
        
        // Stop any currently playing audio
        stopAudio()
        
        // Construct the audio file path
        var audioPath = getAudioPath(for: fileName, recipeTitle: recipeTitle)
        
        // AEC-13: Fallback to English audio if Spanish not found
        if currentLang == .spanish,
           audioPath.path.isEmpty || !FileManager.default.fileExists(atPath: audioPath.path),
           let englishFileName = step.audioFileName {
            print("DEBUG: Spanish audio not found, falling back to English: \(englishFileName)")
            audioPath = getAudioPath(for: englishFileName, recipeTitle: recipeTitle)
        }
        
        print("DEBUG: Final audio path: \(audioPath)")
        
        do {
            // Load and play the audio file
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentAudioFile = fileName
            
            print("DEBUG: Playing audio: \(fileName)")
        } catch {
            print("DEBUG: Failed to play audio \(fileName): \(error)")
            isPlaying = false
            currentAudioFile = nil
        }
    }
    
    func playNotesAudio(for recipeTitle: String, audioFileName: String? = nil, audioFileNameEs: String? = nil) {
        print("DEBUG: playNotesAudio called for recipe: '\(recipeTitle)'")
        
        // Stop any currently playing audio
        stopAudio()
        
        // AEC-13: Use localized audio file name
        let currentLang = LocalizationManager.shared.currentLanguage
        print("DEBUG: Current language: \(currentLang.rawValue)")
        
        // Determine which filename to use based on language
        var notesFileName: String
        if currentLang == .spanish, let esFileName = audioFileNameEs, !esFileName.isEmpty {
            notesFileName = esFileName
            print("DEBUG: Using Spanish notes filename: \(notesFileName)")
        } else {
            notesFileName = audioFileName ?? getNotesFileName(for: recipeTitle)
            print("DEBUG: Using English notes filename: \(notesFileName)")
        }
        
        // Construct the audio file path for notes
        var audioPath = getAudioPath(for: notesFileName, recipeTitle: recipeTitle)
        
        // AEC-13: Fallback to English if Spanish not found
        if currentLang == .spanish,
           (audioPath.path.isEmpty || !FileManager.default.fileExists(atPath: audioPath.path)),
           let englishFileName = audioFileName {
            print("DEBUG: Spanish notes audio not found, falling back to English: \(englishFileName)")
            notesFileName = englishFileName
            audioPath = getAudioPath(for: notesFileName, recipeTitle: recipeTitle)
        }
        
        print("DEBUG: Final notes audio path: \(audioPath)")
        
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
    
    func pauseAudio() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        }
    }
    
    func resumeAudio() {
        if let player = audioPlayer, !player.isPlaying {
            player.play()
            isPlaying = true
        }
    }
    
    func toggleNotesAudio(for recipeTitle: String, audioFileName: String? = nil, audioFileNameEs: String? = nil) {
        // AEC-13: Determine effective filename based on language
        let currentLang = LocalizationManager.shared.currentLanguage
        let effectiveFileName: String
        if currentLang == .spanish, let esFileName = audioFileNameEs, !esFileName.isEmpty {
            effectiveFileName = esFileName
        } else {
            effectiveFileName = audioFileName ?? getNotesFileName(for: recipeTitle)
        }
        
        if currentAudioFile == effectiveFileName {
            if isPlaying {
                pauseAudio()
            } else {
                resumeAudio()
            }
        } else {
            playNotesAudio(for: recipeTitle, audioFileName: audioFileName, audioFileNameEs: audioFileNameEs)
        }
    }
    
    func getNotesFileName(for recipeTitle: String) -> String {
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
            "Resources/Audio/\(brewingMethod)/\(folderName)",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)",
            "Audio/\(brewingMethod)/\(folderName)/\(folderName)_AeroPress",
            "Audio/\(brewingMethod)/\(folderName)/\(folderName)_Classic_AeroPress",
            "Audio/\(brewingMethod)/\(folderName)/\(folderName)s_Ultimate_AeroPress",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(folderName)_AeroPress",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(folderName)_Classic_AeroPress",
            "Audio/\(brewingMethod)/World_Champions/\(folderName)/\(folderName)s_Ultimate_AeroPress"
        ]
        
        for subdirectory in subdirectories {
            print("DEBUG: Checking subdirectory: '\(subdirectory)'") // DEBUG LOG
            
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
            
            // Try with common audio extensions if the specific one failed (mismatch between JSON and file)
            for ext in ["m4a", "mp3", "wav", "aac"] {
                if let url = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: ext, subdirectory: subdirectory) {
                    print("DEBUG: Found audio file via extension fallback in subdir '\(subdirectory)': \(url)")
                    return url
                }
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
        
        // 1. Try exactly as requested (full filename)
        if let path = Bundle.main.url(forResource: fileName, withExtension: nil) {
            print("DEBUG: Found audio file in bundle root (exact match): \(path)")
            return path
        }
        
        // 2. Try with parsed components
        if !fileExtension.isEmpty {
            if let path = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension) {
                print("DEBUG: Found audio file in bundle root (parsed extension): \(path)")
                return path
            }
        }
        
        // 3. Try fallback extensions (CRITICAL: Do this even if extension was provided, in case of mismatch)
        for ext in ["m4a", "mp3", "wav", "aac"] {
            // Skip if we already checked this extension in step 2
            if !fileExtension.isEmpty && ext.lowercased() == fileExtension.lowercased() {
                continue
            }
            
            if let path = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: ext) {
                print("DEBUG: Found audio file via extension fallback in bundle root: \(path)")
                return path
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
            // Updated to match directory structure "French_Press"
            return "French_Press"
        }
        
        // Default to AeroPress for backward compatibility
        return "AeroPress"
    }
    
    private func convertTitleToFolderName(_ title: String) -> String {
        // Convert recipe title to folder name format dynamically
        // Matching Python script logic:
        // 1. Remove special characters (keep alphanumerics and spaces)
        // 2. Replace spaces with underscores
        
        do {
            // Remove non-word characters (except spaces)
            let regex = try NSRegularExpression(pattern: "[^\\w\\s]", options: [])
            let range = NSRange(location: 0, length: title.utf16.count)
            let stripped = regex.stringByReplacingMatches(in: title, options: [], range: range, withTemplate: "")
            
            // Replace spaces (and multiple spaces) with underscores
            let spaceRegex = try NSRegularExpression(pattern: "\\s+", options: [])
            let spaceRange = NSRange(location: 0, length: stripped.utf16.count)
            let folderName = spaceRegex.stringByReplacingMatches(in: stripped, options: [], range: spaceRange, withTemplate: "_")
            
            // Limit length to 50 chars
            if folderName.count > 50 {
                return String(folderName.prefix(50))
            }
            
            return folderName
        } catch {
            print("DEBUG: Regex error in convertTitleToFolderName: \(error)")
            return "Standard_1_Person" // Fallback
        }
    }
    
    func hasAudio(for step: BrewingStep) -> Bool {
        // AEC-13: Check localized audio file (tries Spanish first if language is Spanish)
        let hasAudio = step.localizedAudioFileName != nil
        print("DEBUG: hasAudio check - localizedAudioFileName: \(step.localizedAudioFileName ?? "nil"), result: \(hasAudio)")
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
