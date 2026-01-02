import Foundation
import SwiftUI

class CoffeeFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var roaster: String = ""
    @Published var roastLevel: RoastLevel = .medium
    @Published var process: Process = .washed
    @Published var selectedFlavorTags: Set<FlavorTag> = []
    @Published var selectedCustomTags: Set<String> = []
    @Published var searchText: String = ""
    @Published var notes: String = ""
    
    // New Fields
    @Published var country: String = ""
    @Published var region: String = ""
    @Published var variety: String = ""
    @Published var altitude: String = ""
    @Published var roastDate: Date = Date()
    @Published var hasRoastDate: Bool = false
    
    // OCR-related state
    @Published var extractedFields: ExtractedCoffeeData?
    @Published var isProcessingOCR: Bool = false
    @Published var showingOCRReview: Bool = false
    @Published var showingCameraPicker: Bool = false
    @Published var ocrError: String?
    @Published var showingOCRError: Bool = false
    
    private var editingCoffeeId: UUID?
    private let repository: CoffeeRepository
    private let ocrService = OCRService.shared
    private let textParser = TextParserService.shared
    
    var isEditing: Bool { editingCoffeeId != nil }
    
    init(repository: CoffeeRepository = .shared, coffeeToEdit: Coffee? = nil) {
        self.repository = repository
        if let coffee = coffeeToEdit {
            self.editingCoffeeId = coffee.id
            self.name = coffee.name
            self.roaster = coffee.roaster
            self.roastLevel = coffee.roastLevel
            self.process = coffee.process
            self.selectedFlavorTags = Set(coffee.flavorTags)
            self.selectedCustomTags = Set(coffee.customFlavorTags)
            self.notes = coffee.notes
            
            self.country = coffee.country
            self.region = coffee.region
            self.variety = coffee.variety
            self.altitude = coffee.altitude
            if let date = coffee.roastDate {
                self.roastDate = date
                self.hasRoastDate = true
            }
        }
    }
    
    func save() {
        let coffee = Coffee(
            id: editingCoffeeId ?? UUID(),
            name: name,
            roaster: roaster,
            roastLevel: roastLevel,
            process: process,
            flavorTags: Array(selectedFlavorTags),
            customFlavorTags: Array(selectedCustomTags),
            notes: notes,
            country: country,
            region: region,
            variety: variety,
            altitude: altitude,
            roastDate: hasRoastDate ? roastDate : nil
        )
        
        if isEditing {
            repository.update(coffee)
        } else {
            repository.add(coffee)
        }
    }
    
    func toggleFlavorTag(_ tag: FlavorTag) {
        if selectedFlavorTags.contains(tag) {
            selectedFlavorTags.remove(tag)
        } else {
            selectedFlavorTags.insert(tag)
        }
    }
    
    func toggleCustomTag(_ tag: String) {
        if selectedCustomTags.contains(tag) {
            selectedCustomTags.remove(tag)
        } else {
            selectedCustomTags.insert(tag)
        }
    }
    
    func createCustomTag(_ tagName: String) {
        let trimmed = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Check if it already exists as a predefined tag
        if let existingTag = FlavorTag.allCases.first(where: { $0.rawValue.lowercased() == trimmed.lowercased() }) {
            toggleFlavorTag(existingTag)
        } else {
            // Add as custom tag
            selectedCustomTags.insert(trimmed)
        }
        
        // Clear search after creating
        searchText = ""
    }
    
    var filteredFlavorTags: [FlavorTag] {
        if searchText.isEmpty {
            return Array(FlavorTag.allCases)
        }
        return FlavorTag.allCases.filter { tag in
            tag.rawValue.lowercased().contains(searchText.lowercased())
        }
    }
    
    var canCreateCustomTag: Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        
        // Check if it already exists (predefined or custom)
        let existsAsPredefined = FlavorTag.allCases.contains { $0.rawValue.lowercased() == trimmed.lowercased() }
        let existsAsCustom = selectedCustomTags.contains { $0.lowercased() == trimmed.lowercased() }
        
        return !existsAsPredefined && !existsAsCustom
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - OCR Methods
    
    /// Process an image with OCR and parse extracted text
    func processImageWithOCR(_ image: UIImage) {
        isProcessingOCR = true
        ocrError = nil
        
        Task {
            do {
                let extractedText = try await ocrService.extractText(from: image)
                let parsedData = textParser.parseExtractedText(extractedText)
                
                await MainActor.run {
                    self.extractedFields = parsedData
                    self.isProcessingOCR = false
                    
                    if parsedData.hasAnyData {
                        self.showingOCRReview = true
                    } else {
                        // No data extracted
                        self.ocrError = "No text found in the image. Please try again with a clearer photo."
                        self.showingOCRError = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.isProcessingOCR = false
                    self.ocrError = error.localizedDescription
                    self.showingOCRError = true
                }
            }
        }
    }
    
    /// Apply extracted data to form fields
    func applyExtractedData(_ data: ExtractedCoffeeData) {
        // Only fill empty fields, preserve existing data
        if name.isEmpty, let extractedName = data.name {
            name = extractedName
        }
        if roaster.isEmpty, let extractedRoaster = data.roaster {
            roaster = extractedRoaster
        }
        if country.isEmpty, let extractedCountry = data.country {
            country = extractedCountry
        }
        if region.isEmpty, let extractedRegion = data.region {
            region = extractedRegion
        }
        if variety.isEmpty, let extractedVariety = data.variety {
            variety = extractedVariety
        }
        if altitude.isEmpty, let extractedAltitude = data.altitude {
            altitude = extractedAltitude
        }
        if let extractedRoastLevel = data.roastLevel {
            roastLevel = extractedRoastLevel
        }
        if let extractedProcess = data.process {
            process = extractedProcess
        }
        
        extractedFields = nil
        showingOCRReview = false
    }
    
    /// Clear extracted data without applying
    func clearExtractedData() {
        extractedFields = nil
        showingOCRReview = false
    }
}
