import Foundation
import Combine

class CoffeeListViewModel: ObservableObject {
    @Published var coffees: [Coffee] = []
    private let repository: CoffeeRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CoffeeRepository = .shared) {
        self.repository = repository
        
        repository.$coffees
            .assign(to: \.coffees, on: self)
            .store(in: &cancellables)
    }
    
    func delete(at offsets: IndexSet) {
        repository.delete(at: offsets)
    }
}


