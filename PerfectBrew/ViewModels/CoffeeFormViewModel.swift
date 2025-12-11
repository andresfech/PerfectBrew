import Foundation
import SwiftUI

class CoffeeFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var roaster: String = ""
    @Published var roastLevel: RoastLevel = .medium
    @Published var process: Process = .washed
    @Published var selectedFlavorTags: Set<FlavorTag> = []
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
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
