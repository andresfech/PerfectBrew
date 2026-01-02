import Foundation

/// Service for parsing extracted OCR text and mapping to coffee fields
class TextParserService {
    static let shared = TextParserService()
    
    // Coffee origin keywords
    private let coffeeCountries = [
        "Ethiopia", "Colombia", "Brazil", "Kenya", "Guatemala", "Costa Rica",
        "Panama", "Honduras", "Rwanda", "Burundi", "Tanzania", "Yemen",
        "Indonesia", "India", "Vietnam", "Peru", "Bolivia", "Ecuador",
        "Nicaragua", "El Salvador", "Mexico", "Jamaica", "Haiti", "Dominican Republic"
    ]
    
    private let coffeeRegions = [
        "Yirgacheffe", "Sidamo", "Sidama", "Harrar", "Harar", "Guji", "Limu",
        "Narino", "Huila", "Antioquia", "Cauca", "Tolima", "Quindio",
        "Nyeri", "Kiambu", "Kirinyaga", "Embu", "Meru",
        "Boquete", "Volcan", "Tarrazu", "West Valley", "Central Valley",
        "Blue Mountain", "Yauco", "Maragogype"
    ]
    
    private let coffeeVarieties = [
        "Geisha", "Gesha", "Bourbon", "Typica", "Caturra", "Catuai",
        "Pacamara", "Maragogype", "SL28", "SL34", "Blue Mountain",
        "Java", "Mundo Novo", "MundoNovo", "Pacas", "Villa Sarchi"
    ]
    
    private init() {}
    
    /// Parse extracted OCR text and map to ExtractedCoffeeData
    /// - Parameter text: Raw text extracted from OCR
    /// - Returns: ExtractedCoffeeData with parsed fields
    func parseExtractedText(_ text: String) -> ExtractedCoffeeData {
        var extracted = ExtractedCoffeeData()
        
        // Normalize text: split into lines and words for processing
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        let allWords = text.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
        
        // Extract altitude (look for patterns like "2000m", "2000 masl", "6000 ft")
        extracted.altitude = extractAltitude(from: text)
        
        // Extract roast level (keyword matching)
        extracted.roastLevel = extractRoastLevel(from: text)
        
        // Extract process (keyword matching)
        extracted.process = extractProcess(from: text)
        
        // Extract country and region (position-based heuristics)
        let originInfo = extractOrigin(from: lines, allWords: allWords)
        extracted.country = originInfo.country
        extracted.region = originInfo.region
        
        // Extract variety (keyword matching)
        extracted.variety = extractVariety(from: allWords)
        
        // Extract coffee name (typically largest text, often first line or prominent text)
        extracted.name = extractCoffeeName(from: lines, excluding: [originInfo.country, originInfo.region, extracted.variety].compactMap { $0 })
        
        // Extract roaster (company/brand name, often near top or bottom, contains keywords like "Coffee", "Roasters", etc.)
        extracted.roaster = extractRoaster(from: lines, allWords: allWords)
        
        return extracted
    }
    
    // MARK: - Private Extraction Methods
    
    private func extractAltitude(from text: String) -> String? {
        let altitudePattern = #"(\d+\s*(?:m|masl|meters?|ft|feet|f\.?a\.?s\.?l\.?))"#
        let regex = try? NSRegularExpression(pattern: altitudePattern, options: .caseInsensitive)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range),
           let altitudeRange = Range(match.range(at: 1), in: text) {
            return String(text[altitudeRange]).trimmingCharacters(in: .whitespaces)
        }
        
        return nil
    }
    
    private func extractRoastLevel(from text: String) -> RoastLevel? {
        let lowercased = text.lowercased()
        
        // Check for roast level keywords
        if lowercased.contains("light roast") || lowercased.contains("lightly roasted") || 
           (lowercased.contains("light") && lowercased.contains("roast")) {
            return .light
        } else if lowercased.contains("dark roast") || lowercased.contains("darkly roasted") ||
                  (lowercased.contains("dark") && lowercased.contains("roast")) ||
                  lowercased.contains("espresso roast") {
            return .dark
        } else if lowercased.contains("medium roast") || lowercased.contains("medium") {
            return .medium
        }
        
        return nil
    }
    
    private func extractProcess(from text: String) -> Process? {
        let lowercased = text.lowercased()
        
        if lowercased.contains("natural") || lowercased.contains("dry process") {
            return .natural
        } else if lowercased.contains("honey") || lowercased.contains("miel") {
            return .honey
        } else if lowercased.contains("anaerobic") {
            return .anaerobic
        } else if lowercased.contains("washed") || lowercased.contains("wet process") {
            return .washed
        }
        
        return nil
    }
    
    private func extractOrigin(from lines: [String], allWords: [String]) -> (country: String?, region: String?) {
        var country: String? = nil
        var region: String? = nil
        
        // Search for known coffee countries
        for word in allWords {
            if let foundCountry = coffeeCountries.first(where: { $0.lowercased() == word.lowercased() || word.lowercased().contains($0.lowercased()) }) {
                country = foundCountry
                break
            }
        }
        
        // Search for known regions (prioritize over country if both match same value)
        for line in lines {
            for knownRegion in coffeeRegions {
                if line.lowercased().contains(knownRegion.lowercased()) {
                    region = knownRegion
                    // If region matches a country name, prefer region
                    if country?.lowercased() == knownRegion.lowercased() {
                        country = nil
                    }
                    break
                }
            }
            if region != nil { break }
        }
        
        // Also check individual words for region matches
        if region == nil {
            for word in allWords {
                if let foundRegion = coffeeRegions.first(where: { $0.lowercased() == word.lowercased() }) {
                    region = foundRegion
                    break
                }
            }
        }
        
        return (country: country, region: region)
    }
    
    private func extractVariety(from words: [String]) -> String? {
        for word in words {
            if let variety = coffeeVarieties.first(where: { $0.lowercased() == word.lowercased() }) {
                return variety
            }
        }
        return nil
    }
    
    private func extractCoffeeName(from lines: [String], excluding excludeWords: [String]) -> String? {
        // Coffee name is typically:
        // 1. First substantial line (not just numbers or single words)
        // 2. Longer text blocks
        // 3. Not matching excluded origin/variety words
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip very short lines, numbers only, or excluded words
            if trimmed.count < 3 { continue }
            if trimmed.allSatisfy({ $0.isNumber || $0.isWhitespace || $0.isPunctuation }) { continue }
            if excludeWords.contains(where: { trimmed.lowercased().contains($0.lowercased()) }) { continue }
            
            // Skip common label text that's not the coffee name
            let lowercased = trimmed.lowercased()
            if lowercased.contains("roasted") || lowercased.contains("net weight") ||
               lowercased.contains("grams") || lowercased.contains("oz") ||
               lowercased.contains("best before") || lowercased.contains("roast date") {
                continue
            }
            
            // First substantial line that doesn't match exclusions is likely the coffee name
            return trimmed
        }
        
        return nil
    }
    
    private func extractRoaster(from lines: [String], allWords: [String]) -> String? {
        // Roaster name often contains keywords or is near top/bottom
        let roasterKeywords = ["coffee", "roasters", "roastery", "cafe", "café", "estate", "farm"]
        
        // Check lines near the end (bottom of label)
        let bottomLines = Array(lines.suffix(3))
        for line in bottomLines {
            let lowercased = line.lowercased()
            if roasterKeywords.contains(where: { lowercased.contains($0) }) {
                return line.trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Check lines near the beginning (top of label)
        let topLines = Array(lines.prefix(3))
        for line in topLines {
            let lowercased = line.lowercased()
            if roasterKeywords.contains(where: { lowercased.contains($0) }) {
                return line.trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Fallback: look for any line containing roaster keywords
        for line in lines {
            let lowercased = line.lowercased()
            if roasterKeywords.contains(where: { lowercased.contains($0) }) {
                return line.trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
}

