import Foundation
import Combine

class CoffeeRepository: ObservableObject {
    static let shared = CoffeeRepository()
    
    @Published var coffees: [Coffee] = []
    
    private let fileName = "user_coffees.json"
    
    init() {
        loadCoffees()
    }
    
    // MARK: - CRUD Operations
    
    func add(_ coffee: Coffee) {
        coffees.append(coffee)
        saveCoffees()
    }
    
    func update(_ coffee: Coffee) {
        if let index = coffees.firstIndex(where: { $0.id == coffee.id }) {
            coffees[index] = coffee
            // Update timestamp
            var updatedCoffee = coffee
            updatedCoffee.updatedAt = Date()
            coffees[index] = updatedCoffee
            saveCoffees()
        }
    }
    
    func delete(_ coffee: Coffee) {
        coffees.removeAll { $0.id == coffee.id }
        saveCoffees()
    }
    
    func delete(at offsets: IndexSet) {
        coffees.remove(atOffsets: offsets)
        saveCoffees()
    }
    
    // MARK: - Persistence
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private func saveCoffees() {
        do {
            let data = try JSONEncoder().encode(coffees)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("💾 CoffeeRepository: Saved \(coffees.count) coffees")
        } catch {
            print("❌ CoffeeRepository: Failed to save coffees: \(error)")
        }
    }
    
    private func loadCoffees() {
        // First check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ CoffeeRepository: No saved coffees found (new file)")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            coffees = try JSONDecoder().decode([Coffee].self, from: data)
            print("📂 CoffeeRepository: Loaded \(coffees.count) coffees")
        } catch {
            print("❌ CoffeeRepository: Failed to load coffees: \(error)")
        }
    }
    
    // MARK: - Sample Data (for testing)
    func addSampleData() {
        let sample = Coffee(
            name: "Ethiopia Yirgacheffe",
            roaster: "Perfect Brew Roasters",
            roastLevel: .light,
            process: .washed,
            flavorTags: [.floral, .citrus, .tea],
            notes: "Great with V60"
        )
        add(sample)
    }
}

