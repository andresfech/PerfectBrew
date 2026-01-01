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
    
    private var editingCoffeeId: UUID?
    private let repository: CoffeeRepository
    
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
}
