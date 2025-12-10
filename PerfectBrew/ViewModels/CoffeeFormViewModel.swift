import Foundation
import SwiftUI

class CoffeeFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var roaster: String = ""
    @Published var roastLevel: RoastLevel = .medium
    @Published var process: Process = .washed
    @Published var selectedFlavorTags: Set<FlavorTag> = []
    @Published var notes: String = ""
    
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
            notes: notes
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

