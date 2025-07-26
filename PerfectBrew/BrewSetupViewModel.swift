import Foundation

class BrewSetupViewModel: ObservableObject {
    @Published var coffeeDose: Double = 20.0
    @Published var waterAmount: Double = 340.0
    @Published var waterTemperature: Double = 95.0
    @Published var grindSize: Int = 5
    @Published var brewTime: TimeInterval = 180
}
