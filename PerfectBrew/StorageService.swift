import Foundation
import SwiftUI

class StorageService: ObservableObject {
    @AppStorage("brews") private var brewData: Data?

    func saveBrews(_ brews: [Brew]) {
        if let encoded = try? JSONEncoder().encode(brews) {
            brewData = encoded
        }
    }

    func loadBrews() -> [Brew] {
        if let data = brewData,
           let decoded = try? JSONDecoder().decode([Brew].self, from: data) {
            return decoded
        }
        return []
    }
}
